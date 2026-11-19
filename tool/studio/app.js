// ColimaNight Studio • Lógica de Curaduría & Panel de Administración
const MASTER_PIN = '2026';
let enteredPin = '';
let activeFilter = 'all';
let currentEventType = 'specific'; // 'specific' | 'recurring'
let selectedVenueId = 'el_guachi';

// Catálogo Oficial Verificado de los 30 Establecimientos de Colima y Villa de Álvarez
const VENUES = [
  { id: 'el_guachi', name: 'El Guachi', zone: 'Ignacio Sandoval 1943', category: 'Club & Antro', instagram: '@elguachicruderia', secondaryIg: '@guachirooftop', facebook: 'https://www.facebook.com/profile.php?id=100083754547876' },
  { id: 'costa_carranza', name: 'Cervecería de la Costa - Carranza 1', zone: 'Venustiano Carranza 2090', category: 'Taproom & Terraza', instagram: '@cerveceriadelacosta', facebook: 'https://www.facebook.com/CerveceriadelaCosta', tiktok: '@cerveceriadelacosta' },
  { id: 'dmt_rock_bar', name: 'DMT Rock Bar', zone: 'Santos Degollado 28, Centro', category: 'Rock Bar & Pub', instagram: '@dmtrockbar', facebook: 'https://www.facebook.com/dmtrockbar', tiktok: '@dmtrockbar' },
  { id: 'costa_tercer_anillo', name: 'Cervecería de la Costa - Tercer Anillo', zone: 'Plaza del Carmen', category: 'Taproom & Terraza', instagram: '@cerveceriadelacosta', facebook: 'https://www.facebook.com/CerveceriadelaCosta', tiktok: '@cerveceriadelacosta' },
  { id: 'costa_san_fernando', name: 'Cervecería de la Costa - Terraza San Fernando', zone: 'Plaza San Fernando', category: 'Taproom & Terraza', instagram: '@cerveceriadelacosta', facebook: 'https://www.facebook.com/CerveceriadelaCosta', tiktok: '@cerveceriadelacosta' },
  { id: 'costa_sandoval', name: 'Cervecería de la Costa - Sandoval', zone: 'Ignacio Sandoval 1793', category: 'Taproom & Terraza', instagram: '@cerveceriadelacosta', facebook: 'https://www.facebook.com/CerveceriadelaCosta', tiktok: '@cerveceriadelacosta' },
  { id: 'costa_pablo_silva', name: 'Cervecería de la Costa - Pablo Silva', zone: 'Villa de Álvarez', category: 'Taproom & Terraza', instagram: '@cerveceriadelacosta', facebook: 'https://www.facebook.com/CerveceriadelaCosta', tiktok: '@cerveceriadelacosta' },
  { id: 'costa_carranza_2', name: 'Cervecería de la Costa - Carranza 2', zone: 'Venustiano Carranza 2213', category: 'Taproom & Terraza', instagram: '@cerveceriadelacosta', facebook: 'https://www.facebook.com/CerveceriadelaCosta', tiktok: '@cerveceriadelacosta' },
  { id: 'costa_la_paz', name: 'Cervecería de la Costa - La Paz 1', zone: 'Av. La Paz 135', category: 'Taproom & Terraza', instagram: '@cerveceriadelacosta', facebook: 'https://www.facebook.com/CerveceriadelaCosta', tiktok: '@cerveceriadelacosta' },
  { id: 'costa_la_paz_2', name: 'Cervecería de la Costa - La Paz 2', zone: 'Av. La Paz 160', category: 'Taproom & Terraza', instagram: '@cerveceriadelacosta', facebook: 'https://www.facebook.com/CerveceriadelaCosta', tiktok: '@cerveceriadelacosta' },
  { id: 'costa_griselda_alvarez', name: 'Cervecería de la Costa - Griselda Álvarez', zone: 'Villa de Álvarez', category: 'Taproom & Terraza', instagram: '@cerveceriadelacosta', facebook: 'https://www.facebook.com/CerveceriadelaCosta', tiktok: '@cerveceriadelacosta' },
  { id: 'costa_santa_fe', name: 'Cervecería de la Costa - Santa Fe', zone: 'Real Santa Fe', category: 'Taproom & Terraza', instagram: '@cerveceriadelacosta', facebook: 'https://www.facebook.com/CerveceriadelaCosta', tiktok: '@cerveceriadelacosta' },
  { id: 'colimita_centro', name: 'Cervecería Estación Colimita - Centro', zone: 'Andador Constitución 39', category: 'Taproom & Jardín', instagram: '@cerveceriadecolima', facebook: 'https://www.facebook.com/CerveceriadeColima', tiktok: '@cerveceriadecolima__' },
  { id: 'colimita_constitucion', name: 'Cervecería Estación Colimita - Constitución', zone: 'Av. Constitución 890', category: 'Taproom & Terraza', instagram: '@cerveceriadecolima', facebook: 'https://www.facebook.com/CerveceriadeColima', tiktok: '@cerveceriadecolima__' },
  { id: 'dos_puntos', name: 'Dos Puntos Cervecería', zone: 'Santos Degollado 34, Centro', category: 'Taproom & Bar', instagram: '@dospuntoscerveceria', facebook: 'https://www.facebook.com/CervezaDosPuntos' },
  { id: 'el_taurino', name: 'El Taurino Bar', zone: 'Filomeno Medina 12, Centro', category: 'Cantina Tradicional', instagram: '@el_taurino_colima', facebook: 'https://www.facebook.com/eltaurinoCOLIMA' },
  { id: 'la_puerta_bar', name: 'Bar La Puerta', zone: '27 de Septiembre 135, Centro', category: 'Bar Urbano & Club', instagram: '@barlapuerta', secondaryIg: '@lapuertadelperreo.dog', facebook: 'https://www.facebook.com/LaPuertaBarColima' },
  { id: 'low_social_club', name: 'Low Social Club', zone: 'Miguel Hidalgo 165, Centro', category: 'Club & Loungewear', instagram: '@lowclub.col', facebook: 'https://www.facebook.com/Lowsocialclub', tiktok: '@low.social.club' },
  { id: 'mezcaleria_casa_colima', name: 'Casa Colima Mezcalería', zone: 'Venustiano Carranza 60, Centro', category: 'Mezcalería & Bar', instagram: '@casa.colima.mezcaleria', facebook: 'https://www.facebook.com/profile.php?id=100063620859970', tiktok: '@casa.colima.mezca' },
  { id: 'los_toros_barra_taurina', name: 'Los Toros Barra Taurina', zone: 'Emilio Carranza #164, Centro', category: 'Bar & Botana', instagram: '@lostorosbarrataurina', facebook: 'https://www.facebook.com/eltaurinoCOLIMA' },
  { id: 'almada_cantina', name: 'Almada Cantina Fina', zone: 'Ignacio Sandoval 1906', category: 'Cantina Fina & Bar', instagram: '@almada_cantina.fina', facebook: 'https://www.facebook.com/profile.php?id=61554656578145', tiktok: '@almada.cantina.fina' },
  { id: 'el_gustito', name: 'El Gustito', zone: 'Ignacio Sandoval 1866', category: 'Restaurante Bar', instagram: '@el_gustito_ignacio_sandoval', facebook: 'https://www.facebook.com/elgustitoignaciosandoval' },
  { id: 'la_regional', name: 'La Regional Cantina', zone: 'Ignacio Sandoval 1866', category: 'Cantina Bar', instagram: '@la_regional_cantina', facebook: 'https://www.facebook.com/laregionalcantina' },
  { id: 'la_chintola', name: 'La Chintola Bar', zone: 'Felipe Sevilla del Río 601', category: 'Bar & Botana', instagram: null, facebook: 'https://www.facebook.com/tucasacolimota' },
  { id: 'santo_mezcal', name: 'Santo Mezcal', zone: 'Av. Constitución 1999', category: 'Mezcalería & Cocina', instagram: '@mezcal.santo', facebook: 'https://www.facebook.com/SMezcal', tiktok: '@santo.mezcal.coli' },
  { id: 'foro_dmt', name: 'Foro DMT', zone: 'Santos Degollado 50, Centro', category: 'Foro Cultural & Rock', instagram: '@foro_dmt', facebook: 'https://www.facebook.com/FORODMT', tiktok: '@foro_dmt' },
  { id: 'paraiso_drinks', name: 'Paraíso Drinks Colima', zone: 'Av. de los Diamantes 140', category: 'Bar & Coctelería', instagram: '@paraisodrinkscolima', facebook: 'https://www.facebook.com/profile.php?id=61553948607612' },
  { id: 'cerveceria_chapultepec', name: 'Cervecería Chapultepec', zone: 'Av. Venustiano Carranza #1726', category: 'Bar & Cervecería', instagram: '@cerveceriachapultepeccolima', facebook: 'https://www.facebook.com/cerveceriachapultepeccolima', tiktok: '@lachapu' },
  { id: 'torna', name: 'Torna', zone: 'Venustiano Carranza 2101', category: 'Focaccia & Listening Bar', instagram: '@torna.col', facebook: 'https://www.facebook.com/profile.php?id=61574344913041', tiktok: '@tornabar' },
  { id: 'el_secreto_karaoke', name: 'El Secreto Karaoke Bar', zone: 'Av. Benito Juárez #1000, Local 7', category: 'Bar & Karaoke', instagram: '@elsecreto_bar1', facebook: 'https://www.facebook.com/profile.php?id=61591782338465' },
];

// Estructura de eventos en memoria (venueId -> array de eventos)
let curatedEvents = {};

// Inicialización al cargar la página
document.addEventListener('DOMContentLoaded', async () => {
  // Verificar si ya se ingresó el PIN en la sesión
  if (sessionStorage.getItem('colimanight_studio_auth') === 'true') {
    document.getElementById('pinScreen').style.display = 'none';
  }

  populateVenueSelect();
  await loadCuratedEvents();
  renderVenuesList();
  selectVenue(selectedVenueId);
  updateStats();
  initFormDates();
  setupClipboardAndDropzone();
});

// ============================================================================
// 1. CONTROL DE SEGURIDAD (PIN MAESTRO)
// ============================================================================
function pressPin(num) {
  if (enteredPin.length < 4) {
    enteredPin += num;
    updatePinDots();
  }
  if (enteredPin.length === 4) {
    validatePin();
  }
}

function clearPin() {
  enteredPin = '';
  updatePinDots();
  document.getElementById('pinError').textContent = '';
}

function backspacePin() {
  enteredPin = enteredPin.slice(0, -1);
  updatePinDots();
  document.getElementById('pinError').textContent = '';
}

function updatePinDots() {
  for (let i = 0; i < 4; i++) {
    const dot = document.getElementById(`dot${i}`);
    if (i < enteredPin.length) {
      dot.classList.add('filled');
    } else {
      dot.classList.remove('filled');
    }
  }
}

function validatePin() {
  if (enteredPin === MASTER_PIN) {
    sessionStorage.setItem('colimanight_studio_auth', 'true');
    document.getElementById('pinScreen').style.display = 'none';
    showToast('Acceso autorizado a ColimaNight Studio');
  } else {
    document.getElementById('pinError').textContent = 'PIN Incorrecto. Intenta de nuevo.';
    enteredPin = '';
    setTimeout(updatePinDots, 250);
  }
}

// ============================================================================
// 2. CARGA Y PERSISTENCIA DE DATOS
// ============================================================================
async function loadCuratedEvents() {
  try {
    const res = await fetch('/api/events');
    if (res.ok) {
      curatedEvents = await res.json();
      localStorage.setItem('colimanight_curated_events', JSON.stringify(curatedEvents));
      return;
    }
  } catch (_) {}

  const stored = localStorage.getItem('colimanight_curated_events');
  if (stored) {
    try {
      curatedEvents = JSON.parse(stored);
    } catch (e) {
      curatedEvents = {};
    }
  }
}

async function persistEvents() {
  localStorage.setItem('colimanight_curated_events', JSON.stringify(curatedEvents));

  try {
    await fetch('/api/events', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(curatedEvents, null, 2),
    });
  } catch (_) {}
}

// ============================================================================
// 3. MASTER LIST & SPLIT LAYOUT
// ============================================================================
function populateVenueSelect() {
  const select = document.getElementById('venueSelect');
  select.innerHTML = '<option value="">-- Selecciona un Establecimiento --</option>';
  VENUES.forEach(v => {
    const opt = document.createElement('option');
    opt.value = v.id;
    opt.textContent = `${v.name} (${v.zone})`;
    select.appendChild(opt);
  });
}

function filterVenues() {
  renderVenuesList();
}

function setFilter(filterType, element) {
  activeFilter = filterType;
  document.querySelectorAll('.chip-btn').forEach(b => b.classList.remove('active'));
  if (element) element.classList.add('active');
  renderVenuesList();
}

function renderVenuesList() {
  const container = document.getElementById('venuesList');
  container.innerHTML = '';
  const search = (document.getElementById('searchInput').value || '').toLowerCase().trim();

  VENUES.forEach(venue => {
    const events = curatedEvents[venue.id] || [];
    const hasEvents = events.length > 0;
    const hasRecurring = events.some(e => e.isRecurring);

    // Búsqueda
    const matchesSearch = !search ||
      venue.name.toLowerCase().includes(search) ||
      venue.zone.toLowerCase().includes(search) ||
      venue.category.toLowerCase().includes(search) ||
      (venue.instagram && venue.instagram.toLowerCase().includes(search)) ||
      (venue.secondaryIg && venue.secondaryIg.toLowerCase().includes(search));

    if (!matchesSearch) return;

    if (activeFilter === 'has_events' && !hasEvents) return;
    if (activeFilter === 'empty' && hasEvents) return;
    if (activeFilter === 'recurring' && !hasRecurring) return;

    const isSelected = venue.id === selectedVenueId;
    const item = document.createElement('div');
    item.className = `venue-item ${isSelected ? 'selected' : ''}`;
    item.onclick = () => selectVenue(venue.id);

    let socialBadge = '';
    if (venue.instagram) {
      socialBadge = `📸 ${escapeHtml(venue.instagram)}${venue.secondaryIg ? ` • ${escapeHtml(venue.secondaryIg)}` : ''}`;
    } else if (venue.facebook) {
      socialBadge = `📘 Facebook Oficial`;
    } else {
      socialBadge = `📍 Difusión local`;
    }

    item.innerHTML = `
      <div class="venue-item-top">
        <span class="venue-item-name">${escapeHtml(venue.name)}</span>
        <span class="venue-badge-count ${hasEvents ? 'has-events' : ''}">
          ${hasEvents ? `${events.length} activo(s)` : '—'}
        </span>
      </div>
      <div class="venue-item-sub">
        ${escapeHtml(venue.category)} • ${escapeHtml(venue.zone)}
      </div>
      <div class="venue-item-social">
        ${socialBadge}
      </div>
    `;

    container.appendChild(item);
  });
}

function selectVenue(venueId) {
  selectedVenueId = venueId;
  renderVenuesList();

  const venue = VENUES.find(v => v.id === venueId);
  if (!venue) return;

  // Actualizar banner
  document.getElementById('bannerVenueName').textContent = venue.name;
  document.getElementById('bannerCategory').textContent = venue.category;
  document.getElementById('bannerZone').textContent = venue.zone;

  const bannerIg = document.getElementById('bannerInstagram');
  const bannerIgLink = document.getElementById('bannerInstagramLink');
  const bannerDotSocial = document.getElementById('bannerDotSocial');

  if (venue.instagram) {
    bannerIg.textContent = venue.instagram;
    bannerIg.style.display = 'inline';
    bannerIgLink.href = `https://instagram.com/${venue.instagram.replace('@', '')}/`;
    bannerIgLink.textContent = 'Abrir en Instagram ↗';
    bannerIgLink.style.display = 'inline-flex';
    if (bannerDotSocial) bannerDotSocial.style.display = 'inline';
  } else if (venue.facebook) {
    bannerIg.textContent = 'Facebook Oficial';
    bannerIg.style.display = 'inline';
    bannerIgLink.href = venue.facebook;
    bannerIgLink.textContent = 'Abrir en Facebook ↗';
    bannerIgLink.style.display = 'inline-flex';
    if (bannerDotSocial) bannerDotSocial.style.display = 'inline';
  } else {
    bannerIg.textContent = '';
    bannerIg.style.display = 'none';
    bannerIgLink.removeAttribute('href');
    bannerIgLink.style.display = 'none';
    if (bannerDotSocial) bannerDotSocial.style.display = 'none';
  }

  // Actualizar select del formulario
  document.getElementById('venueSelect').value = venueId;
  const sourceIgInput = document.getElementById('sourceInstagramUrl');
  if (venue.instagram) {
    sourceIgInput.value = `https://www.instagram.com/${venue.instagram.replace('@', '')}/`;
    sourceIgInput.placeholder = 'https://www.instagram.com/...';
  } else if (venue.facebook) {
    sourceIgInput.value = venue.facebook;
    sourceIgInput.placeholder = 'https://www.facebook.com/...';
  } else {
    sourceIgInput.value = '';
    sourceIgInput.placeholder = 'Opcional: Enlace de difusión o flyer';
  }

  renderVenueEvents(venueId);
  prepareNewEvent();
}

function renderVenueEvents(venueId) {
  const container = document.getElementById('venueEventsList');
  const countBadge = document.getElementById('venueEventsCountBadge');
  const events = curatedEvents[venueId] || [];

  countBadge.textContent = `${events.length} publicación(es) activa(s)`;
  container.innerHTML = '';

  if (events.length === 0) {
    container.innerHTML = `
      <div class="empty-state-card">
        <div style="font-size: 28px;">📭</div>
        <div style="font-size: 14px; font-weight: 700; color: #FFF;">Sin cartelera activa en este establecimiento</div>
        <p style="font-size: 12px; max-width: 420px;">
          Actualmente este local no tiene eventos ni promociones vigentes. Completa el formulario de abajo para registrar su primer evento o promo semanal.
        </p>
      </div>
    `;
    return;
  }

  events.forEach((ev, index) => {
    const isRec = ev.isRecurring;
    const badgeClass = isRec ? 'rec' : 'upcoming';
    const badgeText = isRec ? `RECURRENTE • CADA ${getDayName(ev.recurringWeekday)}` : (ev.dateDisplay || 'CONFIRMADO');
    const scheduleDisplay = ev.specialSchedule ? `⏰ ${ev.specialSchedule}` : (ev.dateDisplay ? `📅 ${ev.dateDisplay}` : '⏰ Horario habitual');

    const card = document.createElement('div');
    card.className = 'event-card';

    let thumbHtml = '';
    if (ev.flyerImageUrl) {
      thumbHtml = `
        <div class="event-card-thumb" onclick="openLightbox('${escapeHtml(ev.flyerImageUrl)}')" title="Clic para ampliar flyer">
          <img src="${escapeHtml(ev.flyerImageUrl)}" alt="Flyer" onerror="this.onerror=null; this.parentElement.style.display='none';">
        </div>
      `;
    }

    card.innerHTML = `
      <div class="event-card-main">
        <div class="event-badge-row">
          <span class="event-badge ${badgeClass}">${badgeText}</span>
          <span class="event-schedule-tag">${escapeHtml(scheduleDisplay)}</span>
        </div>
        <div class="event-title-text">${escapeHtml(ev.title)}</div>
        <div class="event-meta-info">
          ${ev.artistOrDj ? `<span>🎵 ${escapeHtml(ev.artistOrDj)}</span>` : ''}
          ${ev.coverPrice ? `<span>🎟️ ${escapeHtml(ev.coverPrice)}</span>` : ''}
          ${ev.sourceInstagramHandle ? `<span>📸 ${escapeHtml(ev.sourceInstagramHandle)}</span>` : ''}
        </div>
        ${ev.promoNote ? `<div class="event-promo-highlight">⚡ ${escapeHtml(ev.promoNote)}</div>` : ''}
      </div>

      ${thumbHtml}

      <div class="event-actions">
        <button type="button" class="icon-btn" onclick="editEvent('${venueId}', '${ev.id}')" title="Editar publicación">✏️</button>
        <button type="button" class="icon-btn delete" onclick="deleteEvent('${venueId}', ${index})" title="Eliminar publicación">🗑️</button>
      </div>
    `;

    container.appendChild(card);
  });
}

function updateStats() {
  document.getElementById('statVenuesCount').textContent = `${VENUES.length} Establecimientos`;

  let totalActive = 0;
  let totalRecurring = 0;

  VENUES.forEach(v => {
    const list = curatedEvents[v.id] || [];
    list.forEach(e => {
      totalActive++;
      if (e.isRecurring) totalRecurring++;
    });
  });

  document.getElementById('statEventsCount').textContent = `${totalActive} Eventos Activos`;
  document.getElementById('statPromosCount').textContent = `${totalRecurring} Promos 2x1`;
}

// ============================================================================
// 4. FORMULARIO INTEGRADO Y EDICIÓN
// ============================================================================
function prepareNewEvent() {
  document.getElementById('editingEventId').value = '';
  document.getElementById('formModeTitle').textContent = `Nueva Publicación para ${getCurrentVenueName()}`;
  document.getElementById('formEditingBadge').style.display = 'none';
  document.getElementById('btnSubmitForm').textContent = '✓ Guardar y Publicar';

  document.getElementById('eventTitle').value = '';
  document.getElementById('eventSchedule').value = '';
  document.getElementById('artistOrDj').value = '';
  document.getElementById('coverPrice').value = '';
  document.getElementById('promoNote').value = '';
  clearUploadedFlyer();
  document.getElementById('flyerUrl').value = '';

  const venue = VENUES.find(v => v.id === selectedVenueId);
  const sourceIgInput = document.getElementById('sourceInstagramUrl');
  if (venue && venue.instagram) {
    sourceIgInput.value = `https://www.instagram.com/${venue.instagram.replace('@', '')}/`;
    sourceIgInput.placeholder = 'https://www.instagram.com/...';
  } else if (venue && venue.facebook) {
    sourceIgInput.value = venue.facebook;
    sourceIgInput.placeholder = 'https://www.facebook.com/...';
  } else {
    sourceIgInput.value = '';
    sourceIgInput.placeholder = 'Opcional: Enlace de difusión o flyer';
  }

  setEventType('specific');
  setQuickDate('today');
}

function editEvent(venueId, eventId) {
  const events = curatedEvents[venueId] || [];
  const ev = events.find(e => e.id === eventId);
  if (!ev) return;

  document.getElementById('editingEventId').value = eventId;
  document.getElementById('formModeTitle').textContent = `Editando: ${ev.title}`;
  document.getElementById('formEditingBadge').style.display = 'inline-block';
  document.getElementById('btnSubmitForm').textContent = '✓ Guardar Cambios';

  document.getElementById('venueSelect').value = venueId;
  document.getElementById('eventTitle').value = ev.title || '';
  document.getElementById('eventSchedule').value = ev.specialSchedule || '';
  document.getElementById('artistOrDj').value = ev.artistOrDj || '';
  document.getElementById('coverPrice').value = ev.coverPrice || '';
  document.getElementById('promoNote').value = ev.promoNote || '';
  document.getElementById('sourceInstagramUrl').value = ev.sourceInstagramUrl || '';

  if (ev.isRecurring) {
    setEventType('recurring');
    if (ev.recurringWeekday) {
      document.getElementById('recurringWeekday').value = String(ev.recurringWeekday);
    }
  } else {
    setEventType('specific');
    if (ev.eventDate) {
      const d = new Date(ev.eventDate);
      const y = d.getFullYear();
      const m = String(d.getMonth() + 1).padStart(2, '0');
      const day = String(d.getDate()).padStart(2, '0');
      document.getElementById('eventDate').value = `${y}-${m}-${day}`;
      const hh = String(d.getHours()).padStart(2, '0');
      const mm = String(d.getMinutes()).padStart(2, '0');
      document.getElementById('eventTime').value = `${hh}:${mm}`;
    }
  }

  // Previsualizar flyer si existe
  if (ev.flyerImageUrl) {
    showFlyerPreview(ev.flyerImageUrl, 'assets/images/venues/flyers/...');
    document.getElementById('flyerUploadedPath').value = ev.flyerImageUrl;
  } else {
    clearUploadedFlyer();
  }

  // Scroll suave hacia el editor
  document.getElementById('editorCard').scrollIntoView({ behavior: 'smooth' });
}

function resetForm() {
  prepareNewEvent();
}

function setEventType(type) {
  currentEventType = type;
  const specBtn = document.getElementById('typeSpecificBtn');
  const recBtn = document.getElementById('typeRecurringBtn');
  const specFields = document.getElementById('specificDateFields');
  const recFields = document.getElementById('recurringDateFields');

  if (type === 'specific') {
    specBtn.classList.add('active', 'spec');
    recBtn.classList.remove('active', 'rec');
    specFields.style.display = 'block';
    recFields.style.display = 'none';
  } else {
    recBtn.classList.add('active', 'rec');
    specBtn.classList.remove('active', 'spec');
    specFields.style.display = 'none';
    recFields.style.display = 'block';
  }
}

function onVenueSelectChange() {
  const venueId = document.getElementById('venueSelect').value;
  if (venueId && venueId !== selectedVenueId) {
    selectVenue(venueId);
  }
}

function initFormDates() {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  document.getElementById('eventDate').value = `${year}-${month}-${day}`;
}

function setQuickDate(target) {
  const now = new Date();
  let targetDate = new Date();

  if (target === 'today') {
    targetDate = now;
  } else {
    const dayMap = { thursday: 4, friday: 5, saturday: 6 };
    const targetDay = dayMap[target];
    let diff = targetDay - now.getDay();
    if (diff < 0) diff += 7;
    targetDate.setDate(now.getDate() + diff);
  }

  const y = targetDate.getFullYear();
  const m = String(targetDate.getMonth() + 1).padStart(2, '0');
  const d = String(targetDate.getDate()).padStart(2, '0');
  document.getElementById('eventDate').value = `${y}-${m}-${d}`;
}

function quickFillTitle(title) {
  document.getElementById('eventTitle').value = title;
}

function quickFillSchedule(scheduleText) {
  document.getElementById('eventSchedule').value = scheduleText;
}

// ============================================================================
// 5. CARGA DE IMÁGENES / CAPTURAS LOCALES & PORTAPAPELES (Ctrl+V)
// ============================================================================
function triggerFilePicker() {
  document.getElementById('flyerFileInput').click();
}

function handleFileSelect(event) {
  const file = event.target.files && event.target.files[0];
  if (file) {
    processAndUploadImage(file);
  }
}

function setupClipboardAndDropzone() {
  const dropzone = document.getElementById('flyerDropzone');

  dropzone.addEventListener('dragover', (e) => {
    e.preventDefault();
    dropzone.classList.add('dragover');
  });

  dropzone.addEventListener('dragleave', () => {
    dropzone.classList.remove('dragover');
  });

  dropzone.addEventListener('drop', (e) => {
    e.preventDefault();
    dropzone.classList.remove('dragover');
    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
      processAndUploadImage(e.dataTransfer.files[0]);
    }
  });

  // Pegar directamente con Ctrl+V (capturas de pantalla)
  window.addEventListener('paste', (e) => {
    const items = (e.clipboardData || e.originalEvent.clipboardData).items;
    for (const item of items) {
      if (item.type.indexOf('image') !== -1) {
        const file = item.getAsFile();
        showToast('Captura detectada en el portapapeles. Subiendo...');
        processAndUploadImage(file);
        break;
      }
    }
  });
}

async function processAndUploadImage(file) {
  const reader = new FileReader();
  reader.onload = async (e) => {
    const base64Data = e.target.result;
    showFlyerPreview(base64Data, 'Procesando en assets...');

    try {
      const venueId = document.getElementById('venueSelect').value || selectedVenueId;
      const res = await fetch('/api/upload', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          venueId,
          filename: file.name || 'clipboard_screenshot.jpg',
          data: base64Data,
        }),
      });

      const json = await res.json();
      if (json.success) {
        document.getElementById('flyerUploadedPath').value = json.assetPath;
        showFlyerPreview(json.previewUrl || base64Data, json.assetPath);
        showToast(`📸 Flyer guardado: ${json.filename}`);
      } else {
        showToast('✕ Error al subir flyer: ' + (json.error || 'Fallo'));
      }
    } catch (err) {
      // Modo offline o fallback estático: mantener dataURL local
      document.getElementById('flyerUploadedPath').value = base64Data;
      showFlyerPreview(base64Data, 'Imagen guardada localmente');
      showToast('📸 Flyer cargado en memoria local');
    }
  };
  reader.readAsDataURL(file);
}

function showFlyerPreview(imgSrc, assetPath) {
  document.getElementById('flyerPreviewImg').src = imgSrc;
  document.getElementById('flyerPreviewAssetPath').textContent = assetPath || '';
  document.getElementById('flyerPreviewContainer').style.display = 'flex';
  document.getElementById('flyerDropzone').style.display = 'none';
}

function clearUploadedFlyer() {
  document.getElementById('flyerUploadedPath').value = '';
  document.getElementById('flyerFileInput').value = '';
  document.getElementById('flyerPreviewImg').src = '';
  document.getElementById('flyerPreviewContainer').style.display = 'none';
  document.getElementById('flyerDropzone').style.display = 'flex';
}

function openLightbox(src) {
  document.getElementById('lightboxImg').src = src;
  document.getElementById('lightboxModal').classList.add('active');
}

function closeLightbox() {
  document.getElementById('lightboxModal').classList.remove('active');
}

// ============================================================================
// 6. GUARDAR EVENTO / PROMOCIÓN
// ============================================================================
async function saveEvent(e) {
  e.preventDefault();
  const venueId = document.getElementById('venueSelect').value || selectedVenueId;
  const editingId = document.getElementById('editingEventId').value;
  const title = document.getElementById('eventTitle').value.trim();
  const specialSchedule = document.getElementById('eventSchedule').value.trim();
  const artistOrDj = document.getElementById('artistOrDj').value.trim();
  const coverPrice = document.getElementById('coverPrice').value.trim() || 'Sin Cover';
  const promoNote = document.getElementById('promoNote').value.trim();
  const flyerUploaded = document.getElementById('flyerUploadedPath').value.trim();
  const flyerUrl = document.getElementById('flyerUrl').value.trim();
  const finalFlyer = flyerUploaded || flyerUrl || null;
  const sourceIg = document.getElementById('sourceInstagramUrl').value.trim();
  const venue = VENUES.find(v => v.id === venueId);

  const isRec = currentEventType === 'recurring';
  let dateDisplay = '';
  let eventDateIso = null;
  let expiresAtIso = null;
  let recurringWeekday = null;

  if (isRec) {
    recurringWeekday = parseInt(document.getElementById('recurringWeekday').value, 10);
    dateDisplay = specialSchedule ? `Cada ${getDayName(recurringWeekday)} • ${specialSchedule}` : `Cada ${getDayName(recurringWeekday)}`;
  } else {
    const dateVal = document.getElementById('eventDate').value; // YYYY-MM-DD
    const timeVal = document.getElementById('eventTime').value; // HH:mm
    const [year, month, day] = (dateVal || '').split('-').map(Number);
    const [hour, minute] = (timeVal || '21:00').split(':').map(Number);

    if (dateVal) {
      const eventDate = new Date(year, month - 1, day, hour, minute);
      eventDateIso = eventDate.toISOString();

      // Corte automático a las 06:00 AM del día posterior
      const cutoffDate = new Date(year, month - 1, day + 1, 6, 0);
      expiresAtIso = cutoffDate.toISOString();

      const dayNames = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
      const monthNames = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      const period = hour >= 12 ? 'PM' : 'AM';
      const hour12 = hour % 12 === 0 ? 12 : hour % 12;
      const minStr = String(minute).padStart(2, '0');
      dateDisplay = `${dayNames[eventDate.getDay()]} ${day} ${monthNames[month - 1]} • ${hour12}:${minStr} ${period}`;
    } else {
      dateDisplay = specialSchedule || 'Próximamente';
    }
  }

  const sourceIgHandle = venue && venue.instagram ? venue.instagram : (venue && venue.facebook ? 'Facebook' : null);

  const eventObj = {
    id: editingId || `ev_${venueId}_${Date.now()}`,
    title,
    dateDisplay,
    eventDate: eventDateIso,
    expiresAt: expiresAtIso,
    specialSchedule: specialSchedule || null,
    artistOrDj: artistOrDj || null,
    coverPrice,
    promoNote: promoNote || null,
    flyerImageUrl: finalFlyer,
    sourceInstagramUrl: sourceIg || null,
    sourceInstagramHandle: sourceIgHandle,
    isRecurring: isRec,
    recurringWeekday: recurringWeekday,
    isStoryAnnouncement: true,
  };

  if (!curatedEvents[venueId]) {
    curatedEvents[venueId] = [];
  }

  if (editingId) {
    const idx = curatedEvents[venueId].findIndex(e => e.id === editingId);
    if (idx !== -1) {
      curatedEvents[venueId][idx] = eventObj;
    } else {
      curatedEvents[venueId].push(eventObj);
    }
  } else {
    curatedEvents[venueId].push(eventObj);
  }

  await persistEvents();
  renderVenuesList();
  renderVenueEvents(venueId);
  updateStats();
  prepareNewEvent();
  showToast(editingId ? `✓ Publicación actualizada para ${venue ? venue.name : venueId}` : `✓ Publicación registrada para ${venue ? venue.name : venueId}`);
}

async function deleteEvent(venueId, index) {
  if (confirm('¿Deseas retirar esta publicación de la cartelera?')) {
    if (curatedEvents[venueId]) {
      curatedEvents[venueId].splice(index, 1);
      if (curatedEvents[venueId].length === 0) {
        delete curatedEvents[venueId];
      }
      await persistEvents();
      renderVenuesList();
      renderVenueEvents(venueId);
      updateStats();
      showToast('Publicación retirada de la cartelera');
    }
  }
}

// ============================================================================
// 7. EXPORTACIÓN Y DESPLIEGUE A GITHUB PAGES
// ============================================================================
function exportDataJson() {
  const jsonStr = JSON.stringify(curatedEvents, null, 2);
  const blob = new Blob([jsonStr], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `curated_events_${new Date().toISOString().slice(0, 10)}.json`;
  a.click();
  URL.revokeObjectURL(url);
  showToast('Archivo JSON de eventos exportado');
}

async function triggerDeploy() {
  showToast('Iniciando exportación y compilación para GitHub Pages...');
  try {
    const res = await fetch('/api/deploy', { method: 'POST' });
    const data = await res.json();
    if (data.success) {
      showToast('✓ Cartelera compilada exitosamente en docs/');
      alert('¡Compilación Exitosa!\n\nPara publicar los cambios en vivo en GitHub Pages, abre tu terminal y ejecuta:\n\ngit add docs assets/data tool/studio/data\ngit commit -m "chore: update cartelera"\ngit push\n\nTu web estará al día en: https://kevmxsr.github.io/ColimaNight/');
    } else {
      showToast('✕ Error al compilar: ' + (data.error || 'Revisa la consola'));
    }
  } catch (e) {
    alert('Para compilar hacia GitHub Pages sin el servidor local activo, ejecuta en la terminal:\n\ndart run tool/export_weekly_events.dart');
  }
}

// ============================================================================
// 8. UTILIDADES
// ============================================================================
function getCurrentVenueName() {
  const venue = VENUES.find(v => v.id === selectedVenueId);
  return venue ? venue.name : 'este local';
}

function getDayName(dayNum) {
  const days = {
    1: 'Lunes',
    2: 'Martes',
    3: 'Miércoles',
    4: 'Jueves',
    5: 'Viernes',
    6: 'Sábado',
    7: 'Domingo',
  };
  return days[dayNum] || 'Día';
}

function escapeHtml(str) {
  if (!str) return '';
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function showToast(msg) {
  const toast = document.getElementById('toast');
  document.getElementById('toastMessage').textContent = msg;
  toast.classList.add('show');
  setTimeout(() => toast.classList.remove('show'), 3500);
}
