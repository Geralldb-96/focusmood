// Cliente de la API de FocusMood. Maneja tokens, renovación de sesión y mapeo de datos de la interfaz.
const BASE = import.meta.env.VITE_API_URL ?? '';
const API = `${BASE}/api/v1`;
const KEY = 'mood-auth';

export class ApiError extends Error {
  constructor(message, status, errors) {
    super(message);
    this.status = status;
    this.errors = errors;
  }
}

let auth = (() => {
  try { return JSON.parse(localStorage.getItem(KEY)); } catch { return null; }
})();

function setAuth(next) {
  auth = next;
  try {
    if (next) localStorage.setItem(KEY, JSON.stringify(next));
    else localStorage.removeItem(KEY);
  } catch { /* almacenamiento no disponible */ }
}

export const hasSession = () => Boolean(auth?.refreshToken);

async function send(path, { method = 'GET', body, token } = {}) {
  let res;
  try {
    res = await fetch(API + path, {
      method,
      headers: {
        ...(body !== undefined ? { 'Content-Type': 'application/json' } : {}),
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      body: body !== undefined ? JSON.stringify(body) : undefined,
    });
  } catch {
    throw new ApiError('No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.', 0);
  }
  if (res.status === 204) return null;
  let data = null;
  try { data = await res.json(); } catch { /* sin cuerpo */ }
  if (!res.ok) {
    const first = data?.errors ? Object.values(data.errors)[0] : null;
    throw new ApiError(first || data?.detail || 'Ocurrió un error inesperado.', res.status, data?.errors);
  }
  return data;
}

let refreshing = null;
function refresh() {
  if (!auth?.refreshToken) return Promise.reject(new ApiError('Sesión expirada', 401));
  refreshing ??= send('/auth/refresh', { method: 'POST', body: { refreshToken: auth.refreshToken } })
    .then(storeSession)
    .catch(err => {
      if (err.status === 401 || err.status === 400) expire();
      throw err;
    })
    .finally(() => { refreshing = null; });
  return refreshing;
}

function expire() {
  setAuth(null);
  window.dispatchEvent(new Event('mood:logout'));
}

async function req(path, opts = {}) {
  if (!auth?.token) await refresh();
  try {
    return await send(path, { ...opts, token: auth.token });
  } catch (err) {
    if (err.status !== 401) throw err;
    await refresh();
    return send(path, { ...opts, token: auth.token });
  }
}

function storeSession(res) {
  setAuth({ token: res.token, refreshToken: res.refreshToken, user: res.user });
  return res;
}

// ---- Auth ----
export const register = (name, email, password) =>
  send('/auth/register', { method: 'POST', body: { name, email, password, confirmPassword: password, acceptTerms: true } })
    .then(storeSession);
export const login = (email, password) =>
  send('/auth/login', { method: 'POST', body: { email, password } }).then(storeSession);
export const forgotPassword = email => send('/auth/forgot-password', { method: 'POST', body: { email } });
export async function logout() {
  try { await req('/auth/logout', { method: 'POST' }); } catch { /* el token local se descarta igual */ }
  setAuth(null);
}

// ---- Perfil ----
export const profile = () => req('/profile');
export const updateProfile = body => req('/profile', { method: 'PUT', body });

// ---- Registro diario y recomendaciones ----
// La interfaz usa sliders 0-10; el modelo del documento usa 1-5 y estados de ánimo discretos.
const MOODS = ['ESTRESADO', 'ANSIOSO', 'TRISTE', 'CANSADO', 'NEUTRAL', 'NEUTRAL', 'CALMADO', 'CALMADO', 'MOTIVADO', 'FELIZ', 'FELIZ'];
const level = v => Math.min(5, Math.max(1, Math.ceil(v / 2)));

async function saveDaily(record) {
  const body = { mood: MOODS[record.mood], energyLevel: level(record.energy), concentrationLevel: level(record.focus) };
  try {
    return await req('/daily-logs', { method: 'POST', body });
  } catch (err) {
    if (err.status !== 409) throw err;
    const today = await req('/daily-logs/today');
    return req(`/daily-logs/${today.id}`, { method: 'PUT', body });
  }
}

export async function recommend(record, duration, activity) {
  const log = await saveDaily(record);
  return req('/recommendations', {
    method: 'POST',
    body: { dailyLogId: log.id, availableMinutes: parseInt(duration, 10) || 15, academicActivity: activity },
  });
}
export const recommendations = () => req('/recommendations');
export const rate = (id, score) => req(`/recommendations/${id}/rating`, { method: 'PUT', body: { score } });

// ---- Hábitos ----
export const habits = () => req('/habits');
export const createHabit = body => req('/habits', { method: 'POST', body });
export const updateHabit = (id, body) => req(`/habits/${id}`, { method: 'PUT', body });
export const deleteHabit = id => req(`/habits/${id}`, { method: 'DELETE' });
export const completeHabit = id => req(`/habits/${id}/completions`, { method: 'POST', body: {} });
export const undoHabit = (id, date) => req(`/habits/${id}/completions/${date}`, { method: 'DELETE' });

// ---- Estudio ----
export const studySessions = () => req('/study-sessions');
export const recordSession = body => req('/study-sessions', { method: 'POST', body });

// ---- Bienestar ----
export const wellnessActivities = () => req('/wellness/activities');
export const logWellness = (activityId, completed) =>
  req('/wellness/logs', { method: 'POST', body: { activityId, completed } });

// ---- Progreso ----
export const weekly = () => req('/progress/weekly');
