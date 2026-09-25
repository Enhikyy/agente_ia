import 'nova_education_assessment.dart';

class NovaResearchCurriculum {
  static const university = <String>['método científico', 'estatística', 'álgebra linear', 'epistemologia', 'ciência da computação', 'aprendizado de máquina', 'ética em inteligência artificial'];
  static const postgraduate = <String>['algoritmos e estruturas de dados', 'análise de complexidade', 'compiladores e teoria dos tipos', 'sistemas operacionais e concorrência', 'testes formais e verificação', 'otimização combinatória e convexa', 'otimização bayesiana', 'aprendizado por reforço', 'aprendizado contínuo', 'hipóteses científicas e reprodutibilidade', 'desenho experimental e estatística', 'eficiência energética', 'segurança e isolamento de agentes', 'linguística geral e teoria das línguas', 'fonologia, morfologia e sintaxe', 'semântica formal e pragmática', 'linguística computacional e gramáticas formais', 'teoria da informação e compressão', 'linguagens construídas e representação simbólica', 'serialização, esquemas e formatos de arquivo versionados'];

  static bool universityCompleted(List<NovaAssessment> exams) => university.every((topic) => exams.any((e) => e.topic == topic && e.passed));
  static String? nextUniversityTopic(List<NovaAssessment> exams) {
    for (final topic in university) {
      if (!exams.any((e) => e.topic == topic && e.passed)) return topic;
    }
    return null;
  }
  static String researchTopic(int session) => postgraduate[session % postgraduate.length];
}
