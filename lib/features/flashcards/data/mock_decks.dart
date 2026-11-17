import '../domain/deck_model.dart';
import '../domain/flashcard_model.dart';

/// Curadoria inicial de decks e flashcards para o MVP do MemoCards.
const List<DeckModel> mockDecks = [
  DeckModel(
    id: '1',
    title: 'Era Vargas',
    description: 'Revisão essencial sobre o período varguista para o ENEM.',
    cards: [
      FlashcardModel(
        id: '101',
        question: 'O que foi a Revolução de 1930?',
        answer:
            'Movimento que depôs Washington Luís e colocou Getúlio Vargas no poder, pondo fim à República Oligárquica.',
      ),
      FlashcardModel(
        id: '102',
        question: 'Qual a principal característica do Estado Novo (1937-1945)?',
        answer:
            'Ditadura de Vargas marcada por centralização, censura (DIP) e criação de direitos trabalhistas (CLT).',
      ),
      FlashcardModel(
        id: '103',
        question: 'O que foi o movimento Queremismo?',
        answer:
            'Movimento popular no fim do Estado Novo que defendia a permanência de Vargas no poder e uma nova constituinte.',
      ),
    ],
  ),
  DeckModel(
    id: '2',
    title: 'Geopolítica Contemporânea',
    description: 'Conceitos fundamentais de Geografia para vestibulares.',
    cards: [
      FlashcardModel(
        id: '201',
        question: 'O que caracteriza a Nova Ordem Mundial?',
        answer:
            'Configuração pós-Guerra Fria, marcada pela multipolaridade econômica e unipolaridade militar (hegemonia dos EUA).',
      ),
      FlashcardModel(
        id: '202',
        question: 'O que é Gentrificação?',
        answer:
            'Revitalização de espaços urbanos que encarece o custo de vida e expulsa a população de baixa renda para as periferias.',
      ),
      FlashcardModel(
        id: '203',
        question: 'Qual a diferença entre Estado e Nação?',
        answer:
            'Estado é a instituição política e jurídica (governo, território). Nação é o sentimento de pertencimento, cultura e identidade de um povo.',
      ),
    ],
  ),
];
