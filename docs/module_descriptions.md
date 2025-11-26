# Documentación de Módulos - Procesador RISC-V Monociclo

Este documento describe en detalle cada archivo fuente (`src/`) y su correspondiente testbench (`tb/`).

## 1. ALU.sv (Unidad Aritmético Lógica)
**Descripción:** Realiza operaciones matemáticas y lógicas (Suma, Resta, AND, OR, XOR, Desplazamientos, Comparaciones).
- **Entradas:** `A`, `B` (Operandos 32-bit), `ALUOp` (Selector de operación 4-bit).
- **Salidas:** `ALURes` (Resultado 32-bit).
- **Detalle:** Usa un `case` para seleccionar la operación basada en `ALUOp`. Soporta operaciones con y sin signo.

## 2. RegisterUnit.sv (Banco de Registros)
**Descripción:** Contiene los 32 registros de propósito general (x0-x31).
- **Entradas:** `Rs1`, `Rs2` (Índices lectura), `Rd` (Índice escritura), `DataWr` (Dato a escribir), `RUWr` (Habilitador escritura).
- **Salidas:** `RURs1`, `RURs2` (Datos leídos).
- **Detalle:** 
    - Lectura asíncrona (combinacional).
    - Escritura síncrona (flanco de reloj).
    - **Importante:** El registro `x0` está cableado a 0 y no se puede sobrescribir.

## 3. ControlUnit.sv (Unidad de Control)
**Descripción:** Decodifica la instrucción y genera señales de control para el resto del procesador.
- **Entradas:** `OpCode`, `Funct3`, `Funct7` (Partes de la instrucción).
- **Salidas:** `RUWr`, `ALUOp`, `ImmSrc`, `DMWr`, `BrOp`, etc.
- **Detalle:** Implementa una máquina de estados (o lógica combinacional pura en monociclo) que mapea cada tipo de instrucción (R-Type, I-Type, Load, Store, Branch) a las señales de control necesarias.

## 4. ImmGen.sv (Generador de Inmediatos)
**Descripción:** Extrae y extiende el signo de los valores inmediatos contenidos en las instrucciones.
- **Entradas:** `Instr` (Instrucción parcial), `ImmSrc` (Selector de tipo).
- **Salidas:** `ImmExt` (Inmediato 32-bit).
- **Detalle:** Maneja formatos I, S, B, U, J. Realiza extensión de signo repitiendo el bit más significativo.

## 5. ProgramCounter.sv (PC)
**Descripción:** Registro que mantiene la dirección de la instrucción actual.
- **Funcionamiento:** Se actualiza en cada ciclo de reloj. Puede resetearse a 0.

## 6. BranchUnit.sv (Unidad de Saltos)
**Descripción:** Decide si se debe tomar un salto condicional o incondicional.
- **Entradas:** `RURs1`, `RURs2` (Valores a comparar), `BrOp` (Tipo de salto).
- **Salidas:** `NextPCSrc` (1 = Saltar, 0 = Siguiente).
- **Detalle:** Compara operandos (Igual, Diferente, Menor, Mayor) y combina el resultado con la señal de salto incondicional.

## 7. Memorias (InstructionMemory y DataMemory)
- **InstructionMemory:** Memoria de solo lectura (ROM conceptual) que contiene el programa. Se inicializa desde `program.hex`.
- **DataMemory:** Memoria RAM para datos. Soporta lectura/escritura de Palabras (32b), Medias Palabras (16b) y Bytes (8b).

## 8. cpu_top.sv (Top Level)
**Descripción:** Módulo integrador que instancia y conecta todos los módulos anteriores.
- **Detalle:** Define los buses internos (`PC`, `ALUResult`, `ReadData`, etc.) y conecta las salidas de un módulo a las entradas del siguiente según la arquitectura Von Neumann/Harvard modificada de RISC-V.

## 9. fpga_top.sv (Wrapper FPGA)
**Descripción:** Adaptador para hardware físico.
- **Detalle:** Invierte el reset (si el botón es activo bajo) y conecta los bits menos significativos del bus de escritura a los LEDs de la placa para visualización.
