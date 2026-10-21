import { CONFIG } from '../config';

const MEXICAN_PROFANITIES = [
  'puto', 'puta', 'pendejo', 'pendeja', 'culero', 'culera', 'chinga', 'chingada',
  'verga', 'madriza', 'verguiza', 'pinche', 'zorra', 'bastardo', 'cabron', 'cabrona',
  'mierda', 'putiza', 'estupido', 'estupida', 'idiota', 'perra', 'maricon', 'golfa'
];

const DEFAMATION_ROLE_TRIGGERS = [
  'cadenero', 'cadeneros', 'dueño', 'dueña', 'gerente', 'mesero', 'mesera',
  'bartender', 'seguridad', 'patron', 'socio', 'socia', 'morra', 'vato'
];

const ACCUSATORY_TERMS = [
  'roba', 'ladron', 'ratero', 'estafador', 'clona', 'clonaron', 'drogas',
  'narco', 'mafia', 'sicario', 'planto', 'acosador', 'violador'
];

const COMMON_NAMES = [
  'juan', 'carlos', 'pedro', 'luis', 'jose', 'miguel', 'jorge', 'fernando', 'alberto',
  'alejandro', 'ricardo', 'daniel', 'rodrigo', 'adrian', 'eduardo', 'manuel', 'hector',
  'maria', 'ana', 'patricia', 'laura', 'andrea', 'sofia', 'paola', 'fernanda', 'daniela'
];

export interface ModerationResult {
  passed: boolean;
  flaggedWords: string[];
  hadNamesOrDefamation: boolean;
  sanitizedText: string;
  toxicityScore: number;
}

/**
 * Normaliza y modera el texto del reporte para proteger la reputación e integridad legal del local.
 * Si se detectan señalamientos a personal o difamación, se neutraliza automáticamente.
 */
export function sanitizeAndModerate(rawComment?: string): ModerationResult {
  if (!rawComment || rawComment.trim().length === 0) {
    return {
      passed: true,
      flaggedWords: [],
      hadNamesOrDefamation: false,
      sanitizedText: '',
      toxicityScore: 0,
    };
  }

  let text = rawComment.trim().substring(0, 120);
  const normalized = text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');

  const words = normalized.split(/[\s,.;:!?()"-]+/);
  const flaggedWords: string[] = [];
  let hadNamesOrDefamation = false;
  let toxicityScore = 0;

  // 1. Filtrado de groserías
  for (const word of words) {
    if (MEXICAN_PROFANITIES.includes(word)) {
      flaggedWords.push(word);
      toxicityScore += 0.25;
      const regex = new RegExp(`\\b${word}\\b`, 'gi');
      text = text.replace(regex, '****');
    }
  }

  // 2. Detección de difamación dirigida: [Rol] + [Nombre]
  for (let i = 0; i < words.length - 1; i++) {
    if (DEFAMATION_ROLE_TRIGGERS.includes(words[i]) && COMMON_NAMES.includes(words[i + 1])) {
      hadNamesOrDefamation = true;
      toxicityScore += 0.5;
      flaggedWords.push(`${words[i]} ${words[i + 1]}`);
    }
  }

  // 3. Detección de acusaciones ilícitas directas
  for (const word of words) {
    if (ACCUSATORY_TERMS.includes(word)) {
      hadNamesOrDefamation = true;
      toxicityScore += 0.4;
      flaggedWords.push(word);
    }
  }

  // 4. Neutralización preventiva
  if (hadNamesOrDefamation || toxicityScore >= 0.7) {
    text = '[Detalle omitido por normas de moderación y prevención de difamación]';
  }

  return {
    passed: toxicityScore < 1.0,
    flaggedWords,
    hadNamesOrDefamation,
    sanitizedText: text,
    toxicityScore: Math.min(toxicityScore, 1.0),
  };
}
