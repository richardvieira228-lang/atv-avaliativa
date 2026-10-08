import 'package:flutter/material.dart';

void main() {
  // O MaterialApp fica aqui para o AlertDialog e o SnackBar funcionarem
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MeuApp()));
}

// Widget principal do app (precisa ser Stateful porque os dados mudam)
class MeuApp extends StatefulWidget {
  @override
  State<MeuApp> createState() => _MeuAppState();
}

// Classe que guarda e controla as informações da tela
class _MeuAppState extends State<MeuApp> {
  // Guarda qual veículo foi escolhido no SegmentedButton
  String veiculo = "Carro Econômico";

  // Guarda se o Checkbox do Seguro está marcado
  bool seguro = false;

  // Guarda se o Checkbox do GPS está marcado
  bool gps = false;

  // Guarda se o Switch do Motorista Adicional está ligado
  bool motorista = false;

  // Guarda o valor do Slider (quantidade de dias)
  double dias = 1;

  // Valores calculados
  int qtd = 1;
  double valorDiario = 0;
  double valorBruto = 0;
  double percentual = 0;
  double desconto = 0;
  double valorFinal = 0;
  String categoria = "";

  void alterarVeiculo(String novoVeiculo) {
    // Método para atualizar o SegmentedButton
    setState(() {
      veiculo = novoVeiculo;
      print(novoVeiculo);
    });
  }

  void alterarSeguro(bool novoValor) {
    // Método para atualizar o Checkbox do Seguro
    setState(() {
      seguro = novoValor;
      print(novoValor);
    });
  }

  void alterarGps(bool novoValor) {
    // Método para atualizar o Checkbox do GPS
    setState(() {
      gps = novoValor;
      print(novoValor);
    });
  }

  void alterarMotorista(bool novoValor) {
    // Método para atualizar o Switch
    setState(() {
      motorista = novoValor;
      print(novoValor);
    });
  }

  void alterarDias(double novoValor) {
    // Método para atualizar o Slider
    setState(() {
      dias = novoValor;
      print(novoValor);
    });
  }

  void calcular() {
    // Calcula tudo da locação (é chamado no início do build)

    // Quantidade de dias sem casas decimais
    qtd = dias.toInt();

    // 1) Valor diário: veículo + seguro + GPS
    if (veiculo == "Carro Econômico") {
      valorDiario = 120;
    } else if (veiculo == "SUV") {
      valorDiario = 180;
    } else {
      valorDiario = 300;
    }

    if (seguro) {
      valorDiario = valorDiario + 40;
    }

    if (gps) {
      valorDiario = valorDiario + 15;
    }

    // 2) Valor diário x dias
    valorBruto = valorDiario * qtd;

    // 3) Taxa fixa do motorista adicional
    if (motorista) {
      valorBruto = valorBruto + 100;
    }

    // Desconto por fidelidade
    if (qtd >= 15) {
      percentual = 10;
    } else if (qtd >= 7) {
      percentual = 5;
    } else {
      percentual = 0;
    }

    desconto = valorBruto * percentual / 100;
    valorFinal = valorBruto - desconto;

    // Desafio extra: categoria do cliente
    if (valorFinal <= 1000) {
      categoria = "Cliente Bronze";
    } else if (valorFinal <= 3000) {
      categoria = "Cliente Prata";
    } else if (valorFinal <= 5000) {
      categoria = "Cliente Ouro";
    } else {
      categoria = "Cliente Platinum";
    }
  }

  String montarResumo() {
    // Monta o texto do resumo (usado na tela e no AlertDialog)

    String textoSeguro = "Não";
    if (seguro) {
      textoSeguro = "Sim";
    }

    String textoGps = "Não";
    if (gps) {
      textoGps = "Sim";
    }

    String textoMotorista = "Não";
    if (motorista) {
      textoMotorista = "Sim";
    }

    return "Veículo: $veiculo\n" +
        "Dias: $qtd\n" +
        "Seguro: $textoSeguro\n" +
        "GPS: $textoGps\n" +
        "Motorista adicional: $textoMotorista\n" +
        "Valor bruto: R\$ ${valorBruto.toStringAsFixed(2)}\n" +
        "Desconto (${percentual.toInt()}%): R\$ ${desconto.toStringAsFixed(2)}\n" +
        "Valor final: R\$ ${valorFinal.toStringAsFixed(2)}\n" +
        "Categoria: $categoria";
  }

  void finalizarReserva() {
    // Mostra o AlertDialog com as informações da locação
    showDialog(
      context: context,
      builder: (contextDialogo) {
        return AlertDialog(
          title: Text("Confirmar Reserva"),

          content: Text(montarResumo()),

          actions: [
            ElevatedButton(
              onPressed: () {
                // Cancelar: só fecha o diálogo
                Navigator.pop(contextDialogo);
              },
              child: Text("Cancelar"),
            ),

            ElevatedButton(
              onPressed: () {
                // Confirmar: fecha o diálogo e mostra o SnackBar
                Navigator.pop(contextDialogo);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Reserva realizada com sucesso!")),
                );
              },
              child: Text("Confirmar Reserva"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Recalcula tudo sempre que a tela é atualizada
    calcular();

    return Scaffold(
      appBar: AppBar(title: Text("Locadora de Carros")), // AppBar
        body: SingleChildScrollView(
          child: Padding(
          padding: EdgeInsets.all(20),

    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= SEGMENTED BUTTON =================
            Text("Veículo (por dia): Econômico R\$ 120 | SUV R\$ 180 | Luxo R\$ 300"),

            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: "Carro Econômico",
                  label: Text("Econômico"),
                ),
                ButtonSegment(value: "SUV", label: Text("SUV")),
                ButtonSegment(value: "Carro de Luxo", label: Text("Luxo")),
              ],

              selected: {veiculo},

              onSelectionChanged: (novaSelecao) {
                alterarVeiculo(novaSelecao.first);
              },
            ), // SegmentedButton

            SizedBox(height: 10),

            // ================= CHECKBOX SEGURO =================
            Text("Seguro Completo (+ R\$ 40 por dia)"),

            Checkbox(
              value: seguro,

              onChanged: (valor) {
                alterarSeguro(valor ?? false);
              },
            ), // Checkbox

            // ================= CHECKBOX GPS =================
            Text("GPS (+ R\$ 15 por dia)"),

            Checkbox(
              value: gps,

              onChanged: (valor) {
                alterarGps(valor ?? false);
              },
            ), // Checkbox

            // ================= SWITCH =================
            Text("Motorista Adicional (taxa fixa R\$ 100)"),

            Switch(
              value: motorista,

              onChanged: (valor) {
                alterarMotorista(valor);
              },
            ), // Switch

            // ================= SLIDER =================
            Text("Quantidade de dias: ${dias.toInt()}"),

            Slider(
              min: 1,
              max: 30,
              value: dias,

              onChanged: (novoValor) {
                alterarDias(novoValor);
              },
            ), // Slider

            // ================= RESUMO =================
            Text("RESUMO DA LOCAÇÃO"),

            Text(montarResumo()),

            SizedBox(height: 10),

            // ================= BOTÃO FINALIZAR =================
            ElevatedButton(
              onPressed: finalizarReserva,
              child: Text("Finalizar Reserva"),
            ), // ElevatedButton
          ],
        ), // Column
      ), // Padding
      ),
    ); // Scaffold
  }
}