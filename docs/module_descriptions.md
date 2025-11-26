# Documentación de Módulos - Procesador RISC-V Segmentado (Pipeline)

Este documento describe en detalle cada archivo fuente (`src/`) y su correspondiente testbench (`tb/`) para la versión segmentada del procesador.

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
    - Lectura asíncrona (combinacional) en etapa ID.
    - Escritura síncrona (flanco de reloj) en etapa WB.
    - **Importante:** El registro `x0` está cableado a 0 y no se puede sobrescribir.

## 3. ControlUnit.sv (Unidad de Control)
**Descripción:** Decodifica la instrucción y genera señales de control para el resto del procesador.
- **Entradas:** `OpCode`, `Funct3`, `Funct7` (Partes de la instrucción).
- **Salidas:** `RUWr`, `ALUOp`, `ImmSrc`, `DMWr`, `BrOp`, etc.
- **Detalle:** Genera todas las señales de control en la etapa ID, las cuales son propagadas a través de los registros del pipeline a las etapas correspondientes (EX, MEM, WB).

## 4. ImmGen.sv (Generador de Inmediatos)
**Descripción:** Extrae y extiende el signo de los valores inmediatos contenidos en las instrucciones.
- **Entradas:** `Instr` (Instrucción parcial), `ImmSrc` (Selector de tipo).
- **Salidas:** `ImmExt` (Inmediato 32-bit).
- **Detalle:** Maneja formatos I, S, B, U, J. Realiza extensión de signo repitiendo el bit más significativo.

## 5. ProgramCounter.sv (PC)
**Descripción:** Registro que mantiene la dirección de la instrucción actual.
- **Funcionamiento:** Se actualiza en cada ciclo de reloj.
- **Cambios Pipeline:** Incluye entrada `En` (Enable) para permitir el estancamiento (stall) del PC en caso de riesgos de datos (Load-Use Hazard).

## 6. BranchUnit.sv (Unidad de Saltos)
**Descripción:** Decide si se debe tomar un salto condicional o incondicional.
- **Ubicación:** Etapa EX (Execution).
- **Entradas:** `RURs1`, `RURs2` (Valores a comparar, pueden ser adelantados), `BrOp` (Tipo de salto).
- **Salidas:** `NextPCSrc` (1 = Saltar, 0 = Siguiente).
- **Detalle:** Compara operandos y decide si tomar el salto. Si se toma, provoca un flush en las etapas anteriores.

## 7. Pipeline_Regs.sv (Registros de Segmentación)
**Descripción:** Módulo que contiene los registros intermedios entre las etapas del pipeline.
- **IF_ID_Reg:** Buffer entre Fetch y Decode.
- **ID_EX_Reg:** Buffer entre Decode y Execute.
- **EX_MEM_Reg:** Buffer entre Execute y Memory.
- **MEM_WB_Reg:** Buffer entre Memory y WriteBack.
- **Detalle:** Cada registro almacena las señales de control y datos necesarios para las etapas subsiguientes. Soportan señales de `clr` (flush) y `en` (stall).

## 8. HazardUnit.sv (Unidad de Riesgos)
**Descripción:** Maneja los riesgos de datos y control para mantener la corrección de la ejecución.
- **Hazard Detection:** Detecta riesgos de uso de carga (Load-Use) y detiene el pipeline (Stall PC e IF/ID).
- **Forwarding Unit:** Adelanta datos desde las etapas MEM y WB hacia la etapa EX para resolver dependencias de datos sin detener el procesador.
- **Control Hazards:** Gestiona el flush del pipeline cuando ocurre un salto.

## 9. Memorias (InstructionMemory y DataMemory)
- **InstructionMemory:** Memoria de solo lectura (ROM conceptual) que contiene el programa. Se inicializa desde `program.hex`.
- **DataMemory:** Memoria RAM para datos. Soporta lectura/escritura de Palabras (32b), Medias Palabras (16b) y Bytes (8b).

## 10. cpu_top.sv (Top Level)
**Descripción:** Módulo integrador que instancia y conecta todos los módulos anteriores en una configuración de pipeline de 5 etapas.
- **Detalle:** 
    - Instancia los registros de pipeline (`IF_ID`, `ID_EX`, `EX_MEM`, `MEM_WB`).
    - Instancia la `HazardUnit` para el control de flujo.
    - Conecta las etapas y gestiona el flujo de datos y control a través del pipeline.

## 11. fpga_top.sv (Wrapper FPGA)
**Descripción:** Adaptador para hardware físico.
- **Detalle:** Invierte el reset (si el botón es activo bajo) y conecta los bits menos significativos del bus de escritura a los LEDs de la placa para visualización.
