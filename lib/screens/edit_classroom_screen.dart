import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_juntos_aprender/components/app_bar.dart';
import 'package:flutter_juntos_aprender/components/decoration_inputs.dart';
import 'package:flutter_juntos_aprender/components/students_modal.dart';
import 'package:flutter_juntos_aprender/controllers/control_classroom.dart';
import 'package:flutter_juntos_aprender/controllers/control_student.dart';
import 'package:flutter_juntos_aprender/models/classroom_model.dart';
import 'package:flutter_juntos_aprender/models/student.model.dart';
import 'package:flutter_juntos_aprender/utils/colors.dart';
import 'package:flutter_juntos_aprender/utils/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditClassroomScreen extends StatefulWidget {
  final ClassroomModel classroom;
  final int index;
  final Function(ClassroomModel classroomModel, int id) onUpdate;

  EditClassroomScreen(
      {required this.classroom, required this.index, required this.onUpdate});

  @override
  _EditClassroomScreenState createState() => _EditClassroomScreenState();
}

class _EditClassroomScreenState extends State<EditClassroomScreen> {
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _quantidadeAlunosController = TextEditingController();
  late DateTime _data;
  late String _fotoPath;
  String _selectedTipoEnsino = 'Ensino Fundamental';

  late ControlClassRoom _controlClassRoom;
  late ControllStudent _controlStudent;

  @override
  void initState() {
    super.initState();
    _controlClassRoom = ControlClassRoom();
    _controlStudent = ControllStudent();
    _nomeController.text = widget.classroom.nomeSala!;
    _quantidadeAlunosController.text =
        widget.classroom.quantidadeAlunos.toString();
    _data = widget.classroom.data;
    _fotoPath = widget.classroom.urlImg ?? '';
    _selectedTipoEnsino = widget.classroom.tipoEnsino ?? 'Ensino Fundamental';
  }

  void _editClassroom(String nome, DateTime date, String urlImg,
      String quantidadeAlunos, String selectedTipoEnsino) {
    if (nome.isEmpty || quantidadeAlunos.isEmpty) {
      showSnackBar(
          context: context,
          texto: 'Por favor, insira todos os campos do formulário!',
          isErro: true);
    } else {
      final editedClassroom = ClassroomModel(
        id: widget.classroom.id,
        nomeSala: nome,
        data: date,
        urlImg: urlImg,
        quantidadeAlunos: int.parse(quantidadeAlunos),
        tipoEnsino: selectedTipoEnsino,
      );

      widget.onUpdate(editedClassroom, widget.index);
      showSnackBar(
          context: context,
          texto: 'Sala atualizada com sucesso!',
          isErro: false);
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    }
  }

  Future<void> _selectData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        _data = picked.add(Duration(hours: 3));
      });
    }
  }

  Future<void> _selectFoto() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _fotoPath = pickedFile.path;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Editar Sala'),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50.0),
                Image.asset('assets/classroom.png', height: 180),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _nomeController,
                  decoration: getInputDecoration('Nome'),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _quantidadeAlunosController,
                  decoration: getInputDecoration('Quantidade de Alunos'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: _data == null
                              ? 'Nenhuma data selecionada!'
                              : 'Data de Criação: ${DateFormat('dd/MM/yyyy').format(_data)}',
                        ),
                        onTap: () => _selectData(context),
                        decoration: getInputDecoration('Data de criação'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecione a data de criação';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                InputDecorator(
                  decoration: getInputDecoration('Tipo de Ensino'),
                  child: DropdownButton<String>(
                    value: _selectedTipoEnsino,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTipoEnsino = newValue!;
                      });
                    },
                    items: <String>['Ensino Fundamental', 'Ensino Médio']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceEvenly, // Ajusta o espaçamento entre os botões
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        String? idClass = await _controlClassRoom
                            .getIdFromIndex(widget.index);
                        List<StudentModel> students = await _controlStudent
                            .getStudentsByIdClass(idClass!);

                        // Mostra a modal com a lista de alunos
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StudentsModal(students: students);
                          },
                        );
                      },
                      child: Text('Exibir Alunos da Sala'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.roxo,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print('Nome: ${_nomeController.text}');
                        print(
                            'Quantidade de Alunos: ${_quantidadeAlunosController.text}');
                        print('Data de criação: $_data');
                        print('Foto Path: $_fotoPath');
                        print('Tipo de Ensino: $_selectedTipoEnsino');
                        _editClassroom(
                          _nomeController.text,
                          _data,
                          _fotoPath,
                          _quantidadeAlunosController.text,
                          _selectedTipoEnsino,
                        );
                      },
                      child: Text('Salvar Alterações'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.roxo, // Background color
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
