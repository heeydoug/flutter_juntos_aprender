import 'package:flutter/material.dart';
import 'package:flutter_juntos_aprender/components/delete_dialog.dart';
import 'package:flutter_juntos_aprender/models/classroom_model.dart';
import 'package:flutter_juntos_aprender/screens/edit_classroom_screen.dart';
import 'package:flutter_juntos_aprender/utils/colors.dart';
import 'package:flutter_juntos_aprender/utils/snackbar.dart';
import 'package:intl/intl.dart';

class ClassroomList extends StatelessWidget {
  final List<ClassroomModel> _classrooms;
  final Function(int id) onRemove;
  final Function(ClassroomModel classroomModel, int id) onUpdate;

  ClassroomList(this._classrooms, this.onRemove, this.onUpdate);

  @override
  Widget build(BuildContext context) {
    //Componente pai para delimitar a area do ListView
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      child: _classrooms.isEmpty
          ? Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Nenhuma sala cadastrada!',
                  style: TextStyle(color: MyColors.roxo),
                ),
                const SizedBox(height: 20),
              ],
            )
          : ListView.builder(
              //Quantidade de itens totais
              itemCount: _classrooms.length,

              //Metodo de criação de cada item
              itemBuilder: (ctx, index) {
                final cl = _classrooms[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 5,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: MyColors.roxo,
                      radius: 30,
                      child: Icon(
                        Icons.home_filled,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    title: Text(
                      cl.nomeSala!,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data de Criação: ' +
                              DateFormat('d MMM y').format(cl.data),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quantidade de Alunos: ${cl.quantidadeAlunos}',
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditClassroomScreen(
                            classroom: cl,
                            index: index,
                            onUpdate: onUpdate,
                          ),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: (() => _showDeleteConfirmationDialog(
                          context, cl.nomeSala, index)),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String nomeSala, int index) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: 'Confirmar Exclusão',
        content: 'Deseja realmente excluir a sala ' + nomeSala + ' ?',
        onCancel: () => Navigator.of(context).pop(),
        onConfirm: () {
          onRemove(index);
          showSnackBar(
              context: context,
              texto: 'Sala excluída com sucesso!',
              isErro: false);
          Navigator.of(context).pop(); // Fecha a dialog
        },
      ),
    );
  }
}
