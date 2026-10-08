import { ModerationResult } from '../types';
import { CONFIG } from '../config';

// Diccionario de groserías, injurias y términos de agresión comunes en México
const MEXICAN_PROFANITY_LIST = [
  'puto', 'puta', 'pendejo', 'pendeja', 'culero', 'culera', 'chinga', 'chingar',
  'chingada', 'verga', 'madriza', 'verguiza', 'pinche', 'zorra', 'bastardo',
  'cabron', 'cabrona', 'mierda', 'putiza', 'estupido', 'estupida', 'idiota',
  'perra', 'maricon', 'putito', 'golfa', 'naco', 'naca'
];

// Palabras clave que denotan señalamientos a personal, roles o acusaciones delictivas directas
const DEFAMATION_ROLE_TRIGGERS = [
  'cadenero', 'cadeneros', 'dueño', 'dueña', 'gerente', 'mesero', 'mesera',
  'bartender', 'seguridad', 'policia', 'patron', 'socio', 'socia', 'morra', 'vato'
];

// Términos acusatorios graves que no corresponden a un reporte de situación en vivo
const ACCUSATORY_TERMS = [
  'roba', 'ladron', 'ratero', 'estafador', 'clona', 'clonaron', 'drogas',
  'narco', 'mafia', 'sicario', 'planto', 'violo', 'acosador', 'violador'
];

// Nombres propios comunes en México para heurística de detección de difamación personal
const COMMON_FIRST_NAMES = [
  'juan', 'carlos', 'pedro', 'luis', 'jose', 'miguel', 'jorge', 'fernando', 'alberto',
  'alejandro', 'ricardo', 'daniel', 'rodrigo', 'adrian', 'eduardo', 'manuel', 'hector',
  'maria', 'ana', 'patricia', 'laura', 'andrea', 'sofia', 'paola', 'fernanda', 'daniela',
  'valeria', 'mariana', 'gabriela', 'camila', 'natalia', 'karen', 'brenda', 'diana'
];

/**
 * Normaliza texto eliminando acentos, caracteres especiales repetidos y convirtiendo a minúsculas.
 */
function normalizeText(text: string): string {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '') // Quita acentos
    .replace(/(.)\1{2,}/g, '$1$1'); // Reduce letras triplicadas (ej. "peeeelea" -> "peelea")
}

/**
 * Sanitiza y modera el texto del reporte para blindar la plataforma contra demandas por difamación.
 * 
 * Reglas:
 * 1. Longitud máxima truncada.
 * 2. Si se detecta mención de persona específica (rol + nombre propio) o términos acusatorios difamatorios,
 *    el comentario se neutraliza automáticamente.
 * 3. Las groserías se censuran con asteriscos.
 * 4. Si la toxicidad excede el umbral, se descarta el texto libre y solo se mantiene la categoría objetiva.
 */
export function sanitizeAndModerateComment(rawComment?: string): ModerationResult {
  if (!rawComment || rawComment.trim().length === 0) {
    return {
      passed: true,
      flaggedWords: [],
      hadNamesOrDefamation: false,
      sanitizedText: '',
      toxicityScore: 0,
    };
  }

  // Truncar a longitud máxima
  let sanitized = rawComment.trim().substring(0, CONFIG.MAX_COMMENT_LENGTH);
  const normalized = normalizeText(sanitized);
  const words = normalized.split(/[\s,.;:!?()"-]+/);

  const flaggedWords: string[] = [];
  let hadNamesOrDefamation = false;
  let toxicityScore = 0;

  // 1. Detección de groserías e insultos
  for (const word of words) {
    if (MEXICAN_PROFANITY_LIST.includes(word)) {
      flaggedWords.push(word);
      toxicityScore += 0.25;
      // Reemplazo en el texto sanitizado
      const regex = new RegExp(`\\b${word}\\b`, 'gi');
      sanitized = sanitized.replace(regex, '****');
    }
  }

  // 2. Detección de difamación dirigida: Patrón [Rol] + [Nombre Propio]
  // Ejemplo: "el cadenero Juan", "el mesero Pedro", "el dueño Carlos"
  for (let i = 0; i < words.length - 1; i++) {
    const currentWord = words[i];
    const nextWord = words[i + 1];

    if (DEFAMATION_ROLE_TRIGGERS.includes(currentWord) && COMMON_FIRST_NAMES.includes(nextWord)) {
      hadNamesOrDefamation = true;
      toxicityScore += 0.5;
      flaggedWords.push(`${currentWord} ${nextWord}`);
    }
  }

  // 3. Detección de términos acusatorios difamatorios
  for (const word of words) {
    if (ACCUSATORY_TERMS.includes(word)) {
      hadNamesOrDefamation = true;
      toxicityScore += 0.4;
      flaggedWords.push(word);
    }
  }

  // 4. Si contiene difamación personal o acusaciones a terceros, redactar por completo
  if (hadNamesOrDefamation || toxicityScore >= 0.7) {
    sanitized = '[Detalle omitido por normas de moderación y prevención de difamación]';
  }

  return {
    passed: toxicityScore < 1.0,
    flaggedWords,
    hadNamesOrDefamation,
    originalText: rawComment,
    sanitizedText: sanitized,
    toxicityScore: Math.min(toxicityScore, 1.0),
  };
}
