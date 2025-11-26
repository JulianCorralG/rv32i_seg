# Procesador Monociclo RISC-V (RV32I)

Este repositorio contiene la implementación de un procesador monociclo basado en la arquitectura RISC-V (RV32I), desarrollado para el curso de Arquitectura de Computadores.

## 1. Objetivos
- Implementar un procesador funcional capaz de ejecutar un subconjunto de instrucciones RV32I.
- Verificar cada módulo y el sistema completo mediante testbenches en SystemVerilog.
- Preparar el diseño para su síntesis e implementación en FPGA.

## 2. Estructura del Proyecto
```
rv32i_mono/
├── src/            # Código fuente RTL (SystemVerilog)
│   ├── cpu_top.sv  # Top-level del procesador
│   ├── fpga_top.sv # Wrapper para implementación en FPGA
│   └── ...         # Otros módulos (ALU, ControlUnit, etc.)
├── tb/             # Testbenches
│   ├── alu_tb.sv
│   ├── regfile_tb.sv
│   ├── cpu_tb.sv
│   └── fpga_tb.sv
├── sim/            # Archivos de simulación (.vvp, .vcd)
├── docs/           # Documentación adicional
├── program.hex     # Programa de prueba en código máquina
└── README.md
```

## 3. Dependencias
- **Icarus Verilog**: Para compilación y simulación.
- **GTKWave** o extensión **WaveTrace** (VSCode): Para visualizar formas de onda.

## 4. Compilación y Simulación

### Ejecutar Testbenches
Desde la raíz del proyecto, utilice los siguientes comandos:

**ALU:**
```bash
iverilog -g2012 -o sim/alu_tb.vvp tb/alu_tb.sv src/ALU.sv
vvp sim/alu_tb.vvp
```

**Banco de Registros:**
```bash
iverilog -g2012 -o sim/regfile_tb.vvp tb/regfile_tb.sv src/RegisterUnit.sv
vvp sim/regfile_tb.vvp
```

**Procesador Completo (CPU Top):**
```bash
iverilog -g2012 -o sim/cpu_tb.vvp -I src tb/cpu_tb.sv src/*.sv
vvp sim/cpu_tb.vvp
```

**Wrapper FPGA:**
```bash
iverilog -g2012 -o sim/fpga_tb.vvp -I src tb/fpga_tb.sv src/*.sv
vvp sim/fpga_tb.vvp
```

## 5. Reproducción de Resultados
1.  Compile y ejecute `cpu_tb.sv` como se indica arriba.
2.  Abra el archivo generado `sim/cpu_tb.vcd` en su visualizador de ondas.
3.  Verifique que el registro `x3` (o la señal interna correspondiente) alcance el valor `15` (0x0F) al final de la simulación, lo que confirma la ejecución correcta del programa de prueba (`program.hex`):
    - `addi x1, x0, 5`
    - `addi x2, x0, 10`
    - `add x3, x1, x2` -> Resultado 15.

## 6. Implementación en FPGA
El archivo `src/fpga_top.sv` está listo para ser usado como *Top Level Entity* en Quartus o Vivado.
- **Entradas**: `clk`, `rst_n` (Reset activo bajo).
- **Salidas**: `LEDS` (16 bits, muestran `WriteData`).
