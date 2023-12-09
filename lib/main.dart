import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting('ru_RU', null).then((_) {
    // инициализируем локализацию для форматирования дат и времени на русском языке
    runApp(const CalendarApp());
  });
}

class CalendarApp extends StatelessWidget {
  const CalendarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate; // хранит выбранную дату в календаре (текущую)
  DateTime? _highlightedDate; // хранит выделенную дату в календаре

  @override
  void initState() {
    super.initState(); // вызов метода initState() у родительского класса State
    _selectedDate = DateTime.now(); // присваеваем переменной текущую дату
  }

  void _selectDate(DateTime date) {
    // метод, который вызывается при выборе даты в календаре
    setState(() {
      _highlightedDate = date; // устанавливает переданную дату в качестве выделенной
    });
  }

  void _previousMonth() { // предыдущий месяц
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year, // оставляем тот же год
        _selectedDate.month - 1, // берем предыдущий месяц
        _selectedDate.day, // оставляем тот же день
      );
      _highlightedDate = null; // снимаем выделение с выбранной даты
    });
  }

  void _nextMonth() { // следующий месяц
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + 1,
        _selectedDate.day,
      );
      _highlightedDate = null;
    });
  }

  void _goToCurrentMonth() { // возврат к текущей дате
    setState(() {
      _selectedDate = DateTime.now(); // присваеваем к переменной текущую дату
      _highlightedDate = null; // снимаем выделение с выбранной даты
    });
  }

  Widget _buildWeekdayCell(String label) { // дни недели
    Color textColor = Colors.black;

    if (label == 'сб' || label == 'вс') {
      textColor = Colors.red;
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  List<String> _getWeekdayLabels() { // список дней недели
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1)); // получаем первый день недели и вычитаем 1 чтобы первый день был понедельник, а не воскресенье
    return List.generate(7, (index) { // генерируем список из 7 дней по индексам от 0 до 6
      final day = firstDayOfWeek.add(Duration(days: index));
      return DateFormat.E('ru_RU').format(day);
    });
  }

  int get firstDayOffset { // значение дня недели для первого дня месяца
    final int weekdayFromMonday =
        DateTime(_selectedDate.year, _selectedDate.month, 1).weekday - 1; // вычитаем 1 из значения дня недели, чтобы привести его в диапазон от 0 до 6, где 0 представляет понедельник, а 6 - воскресенье

    return (weekdayFromMonday - (DateTime.monday - 1)) % 7; // получаем разницу и получаем остаток от деления на 7, например если остаток равен 1, значит первый день находится на вторнике
  }

  bool isCurrentMonth(DateTime date) {
    final now = DateTime.now(); // переменная содержит дату и время
    return date.year == now.year && date.month == now.month; // сравнение переданного года и месяца с текущим годом и месяцем
  }

  bool isCurrentDate(DateTime date) {
    return date.day == _selectedDate.day && isCurrentMonth(date); // проверяет, является ли date текущим месяцем и годом
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь'),
      ),
      body: Column(
        children: [
          // Верхняя панель с кнопками для переключения месяцев
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton( // кнопка возврата на предыдущий месяц
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousMonth,
              ),
              Text( // месяц и год
                DateFormat.yMMMM('ru_RU').format(_selectedDate), // текущая дата месяц и год
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              IconButton( // кнопка перехода на следующий месяц
                icon: const Icon(Icons.arrow_forward),
                onPressed: _nextMonth,
              ),
            ],
          ),
          // Таблица с ярлыками дней недели
          Table(
            children: [
              TableRow(
                children: _getWeekdayLabels()
                    .map((label) => _buildWeekdayCell(label)) // применяет функцию _buildWeekdayCell к каждому элементу списка ярлыков дней недели
                    .toList(), // преобразует результат map обратно в список.
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Сетка с ячейками для отображения дней месяца
          Expanded(
            child: GridView.builder( // строим сетку
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( // создает сетку с фиксированным количеством ячеек в строке
                crossAxisCount: 7, // 7 ячеек в строке
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: // количество ячеек в сетке
                  DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day + firstDayOffset, // количество дней в текущем месяце плюс firstDayOffset - смещение, которое определяет, с какого дня недели начинается месяц
              itemBuilder: (context, index) {
                final day = index + 1 - firstDayOffset;
                if (day <= 0 || day > DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day) {
                  // Число меньше 1 или больше количества дней в месяце - не отображаем его
                  return Container();
                }
                // переменная date, которая представляет дату, соответствующую текущей ячейке в сетке
                final date = DateTime(_selectedDate.year, _selectedDate.month, day);
                // определяет, будет ли текущая ячейка выделена. Она устанавливается в true, если _highlightedDate (выделенная дата) не равна null и если date (дата текущей ячейки) равна _highlightedDate.
                final isHighlighted = _highlightedDate != null && date == _highlightedDate; 

                return GestureDetector(
                  onTap: () => _selectDate(date), // при нажатии выдляет дату
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCurrentDate(date) && isCurrentMonth(date) ? Colors.blue : null,
                      borderRadius: BorderRadius.circular(8),
                      border: isHighlighted
                          ? Border.all(
                              color: Colors.red,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        day.toString(),
                        style: TextStyle(
                          color:
                              isCurrentDate(date) ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Кнопка для перехода к текущему месяцу
          // if (!isCurrentMonth(DateTime.now()))
            ElevatedButton(
            onPressed: _goToCurrentMonth,
            style: ElevatedButton.styleFrom(
              primary: Colors.blue, // Цвет фона кнопки
              onPrimary: Colors.white, // Цвет текста кнопки
              padding: const EdgeInsets.symmetric(horizontal: 16), // Отступы внутри кнопки
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Закругленные углы кнопки
              ),
            ),
            child: const Text('Перейти к текущему месяцу'),
          ),
        ],
      ),
    );
  }
}
