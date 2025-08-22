# SystemVerilog Microarchitecture Challenge for AI No.2. Adding the Flow Control.

This repository contains a new challenge to any AI software that claims to
generate Verilog code. The challenge is based on a very typical scenario in
an electronic company: an engineer has to write a pipelined block using a
library of sub-blocks written by somebody else. Then this engineer has to
verify his block using a testbench written by somebody else. He may also
need to figure out the sub-block latencies and handshakes by analyzing the
code, since a lot of code in electronic companies is not sufficiently
documented.

The SystemVerilog Microarchitecture Challenge for AI No.2 is based on the
[SystemVerilog
Homework](https://github.com/verilog-meetup/systemverilog-homework) project
by [Verilog Meetup](https://verilog-meetup.com/). It also uses the source
code of an open-source [Wally CPU](https://github.com/openhwgroup/cvw).

This challenge is a sequel to the [SystemVerilog Microarchitecture Challenge for AI No.1](https://github.com/verilog-meetup/systemverilog-microarchitecture-challenge-for-ai-1)
which was challenging to ChatGPT 4 but became less challenging when ChatGPT 5 appeared.

## 1. The Prompt

Finish the code of a pipelined block in the file challenge.sv. The block
computes a formula "a ** 5 + 0.3 * b - c". Ready/valid handshakes for the
arguments and the result follow the same rules as ready/valid in AXI Stream.
When a block is not busy, arg_rdy should be 1, it should not wait for
arg_vld. You are not allowed to implement your own submodules or functions
for the addition, subtraction, multiplication, division, comparison or
getting the square root of floating-point numbers. For such operations you
can only use the modules from the arithmetic_block_wrappers directory. You
are not allowed to change any other files except challenge.sv. You can check
the results by running the script "simulate". If the script outputs "FAIL"
or does not output "PASS" from the code in the provided testbench.sv by
running the provided script "simulate", your design is not working and is
not an answer to the challenge. Your design must be able to accept a new set
of the inputs (a, b and c) each clock cycle back-to-back and generate the
computation results without any stalls and without requiring empty cycle
gaps in the input. The solution code has to be synthesizable SystemVerilog
RTL. Your design cannot use more than 10 arithmetic blocks from
arithmetic_block_wrappers directory or more than 10000 D-flip-flops or other
state elements outside those arithmetic blocks. The solution also cannot use
any SRAM or other embedded memory blocks. A human should not help AI by
tipping anything on latencies or handshakes of the submodules. The AI has to
figure this out by itself by analyzing the code in the repository
directories. Likewise a human should not instruct AI how to build a pipeline
structure since it makes the exercise meaningless.

## 2. The Credits

The list of people who contributed to the SystemVerilog Homework:

1. [Yuri Panchul](https://github.com/yuri-panchul)

2. [Mike Kuskov](https://github.com/unaimillan)

3. [Maxim Kudinov](https://github.com/max-kudinov)

4. [Kiran Jayarama](https://github.com/24x7fpga)

5. [Maxim Trofimov](https://github.com/maxvereschagin)

6. [Alexey Fedorov](https://github.com/32FedorovAlexey)

7. [Konstantin Blokhin](https://github.com/kost-b)

8. [Petr Dynin](https://github.com/PetrDynin)

## 3. The recommended software installation

We tested the Challenge with Icarus Verilog 12.0, but you should be able to
run it with other simulators, such as Synopsys VCS, Cadence Xcelium, Mentor
Questa. However, since we did not test the Challenge under other simulators
yet, we suggest checking the result using Icarus Verilog first. Icarus is
available under Linux, MacOS and Windows, with or without Windows WSL. We
also recommend using Bash, even under Windows without WSL. Git for Windows
includes Bash. You may also need GTKWave or Surfer waveform viewer for
debug. To install the necessary software, do the following:

### 3.1. Debian-derived Linux, Simply Linux or Windows WSL Ubuntu

```bash
sudo apt-get update
sudo apt-get install git iverilog gtkwave surfer
```

If you use other Linux distribution, google how to install Git, Icarus
Verilog, GTKWave and optional Surfer.

Check the version of Icarus is at least 11 and preferably 12.

```bash
iverilog -v
```

If not, [build Icarus Verilog from the source](https://github.com/steveicarus/iverilog).

### 3.2. Windows without WSL

Install [Git for Windows](https://gitforwindows.org/) and [Icarus Verilog for Windows](https://bleyer.org/icarus/iverilog-v12-20220611-x64_setup.exe).

### 3.3. MacOS

Use [brew](https://formulae.brew.sh/formula/icarus-verilog):

```zsh
brew install icarus-verilog
```
