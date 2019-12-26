import 'dart:io';

import 'package:agendacontatos/helpers/contato_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContatoPage extends StatefulWidget {
  final Contato contato;

  ContatoPage({this.contato});

  @override
  _ContatoPageState createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _foneController = TextEditingController();
  final _nameFocus = FocusNode();

  Contato _contatoEditado;
  bool _editou = false;

  @override
  void initState() {
    super.initState();
    if (widget.contato == null)
      _contatoEditado = Contato();
    else {
      _contatoEditado = Contato.fromMap(widget.contato.toMap());
      _nameController.text = _contatoEditado.name;
      _emailController.text = _contatoEditado.email;
      _foneController.text = _contatoEditado.fone;
    }
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_contatoEditado.name ?? "Novo contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_contatoEditado.name != null && _contatoEditado.name.isNotEmpty)
              Navigator.pop(context, _contatoEditado);
            else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _contatoEditado.img != null
                              ? FileImage(File(_contatoEditado.img))
                              : AssetImage("images/person.png"))),
                ),
                onTap: (){
                  ImagePicker.pickImage(source: ImageSource.camera).then(
                      (file){
                        if(file == null)
                          return;
                        else
                          setState(() {
                            _contatoEditado.img = file.path;
                          });
                      }
                  );
                },
              ),
              TextField(
                focusNode: _nameFocus,
                controller: _nameController,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text) {
                  _editou = true;
                  setState(() {
                    _contatoEditado.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text) {
                  _editou = true;
                  _contatoEditado.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _foneController,
                decoration: InputDecoration(labelText: "Fone"),
                onChanged: (text) {
                  _editou = true;
                  _contatoEditado.fone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

 Future<bool> _requestPop(){
    if(_editou){
      showDialog(context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Descartar alterações?"),
              content: Text("Se sair as alterações serão perdidas"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Não"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: (){
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          }
      );
      return Future.value(false);
    }
    else{
      return Future.value(true);
    }
  }
}
