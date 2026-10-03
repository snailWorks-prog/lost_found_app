enum ItemType { lost, found }
enum ClaimStatus { pending, accepted, rejected }

class CampusItem {
  final String id;
  final String title;
  final String description;
  final String location;
  final String date;
  final ItemType type;
  final String category;
  final bool isResolved;

  const CampusItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.type,
    required this.category,
    this.isResolved = false,
  });
}

class ChatMessage {
  final String text;
  final String time;
  final bool isMe;

  const ChatMessage({
    required this.text,
    required this.time,
    required this.isMe,
  });
}

class CampusClaim {
  final String id;
  final String itemTitle;
  final String proofDescription;
  final String date;
  final ClaimStatus status;

  const CampusClaim({
    required this.id,
    required this.itemTitle,
    required this.proofDescription,
    required this.date,
    required this.status,
  });
}

const mockItems = [
  CampusItem(
    id: '1',
    title: 'Студенческий билет TI-236',
    description: 'Синяя пластиковая карта на имя Семиона Георгиева. Оставлена на третьем ряду.',
    location: 'Корпус 3, ауд. 3-215',
    date: '2 окт, 14:15',
    type: ItemType.found,
    category: 'Документы',
  ),
  CampusItem(
    id: '2',
    title: 'Ключи от общежития с синим брелоком',
    description: 'Связка из трёх ключей и круглый чип от домофона общежития №2.',
    location: 'Спортивная площадка / сквер',
    date: '2 окт, 16:40',
    type: ItemType.lost,
    category: 'Ключи',
  ),
  CampusItem(
    id: '3',
    title: 'Калькулятор Casio fx-991EX',
    description: 'Черно-белый научный калькулятор, сзади наклейка с формулой Эйлера.',
    location: 'Читальный зал библиотеки',
    date: '1 окт, 11:20',
    type: ItemType.found,
    category: 'Электроника',
  ),
  CampusItem(
    id: '4',
    title: 'Беспроводные наушники в белом кейсе',
    description: 'Кейс поцарапан с правой стороны, внутри один левый наушник.',
    location: 'Столовая главного корпуса',
    date: '1 окт, 13:05',
    type: ItemType.lost,
    category: 'Электроника',
  ),
  CampusItem(
    id: '5',
    title: 'Конспект по PAM и дискретной математике',
    description: 'Тетрадь 96 листов в зелёную клетку, на первой странице надпись TI-236.',
    location: 'Корпус 3, коворкинг 4 этаж',
    date: '30 сен, 17:30',
    type: ItemType.found,
    category: 'Учёба',
  ),
  CampusItem(
    id: '6',
    title: 'Худи тёмно-синее с логотипом UTM',
    description: 'Размер L, забыто на вешалке в гардеробе после лекции по сетям.',
    location: 'Корпус 3, гардероб 1 этажа',
    date: '30 сен, 15:00',
    type: ItemType.lost,
    category: 'Одежда',
  ),
  CampusItem(
    id: '7',
    title: 'Флешка Kingston 64GB',
    description: 'Металлический корпус, на шнурке. Внутри файлы лабораторных работ.',
    location: 'Лаборатория 3-412',
    date: '29 сен, 18:10',
    type: ItemType.found,
    category: 'Электроника',
    isResolved: true,
  ),
  CampusItem(
    id: '8',
    title: 'Пропуск в лабораторию микроэлектроники',
    description: 'Белая бесконтактная карта в прозрачном бейдже на красной ленте.',
    location: 'Холл корпуса 3 возле турникетов',
    date: '28 сен, 09:15',
    type: ItemType.found,
    category: 'Документы',
  ),
];

const mockMessages = [
  ChatMessage(
    text: 'Здравствуйте! Я нашёл студенческий в 3-215 после третьей пары.',
    time: '14:35',
    isMe: false,
  ),
  ChatMessage(
    text: 'Приветствую! Да, это точно мой, я как раз сидел на третьем ряду у окна.',
    time: '14:38',
    isMe: true,
  ),
  ChatMessage(
    text: 'Отлично! Можете забрать сегодня до 17:00 в холле 3 корпуса?',
    time: '14:40',
    isMe: false,
  ),
  ChatMessage(
    text: 'Договорились, буду около 16:30 у турникетов. Спасибо огромное!',
    time: '14:42',
    isMe: true,
  ),
];

const mockClaims = [
  CampusClaim(
    id: 'c1',
    itemTitle: 'Студенческий билет TI-236',
    proofDescription: 'Выдан на моё имя (Георгиев Семион), внутри фото с первого курса.',
    date: '2 окт, 14:30',
    status: ClaimStatus.accepted,
  ),
  CampusClaim(
    id: 'c2',
    itemTitle: 'Ключи от общежития с синим брелоком',
    proofDescription: 'На синем брелоке гравировка с номером комнаты 412.',
    date: '2 окт, 17:10',
    status: ClaimStatus.pending,
  ),
];