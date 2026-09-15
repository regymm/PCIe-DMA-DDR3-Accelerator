# PCIe-DMA-DDR3-accelerator

Under Construction!

Affordable Kintex-7 FPGA cards with DDR3 and PCIe have recently become accessible, but the open-source tooling and gateware ecosystem has not yet caught up.
This project aims to bridge the gap by having an open accelerator platform: a Raspberry Pi with PCIe root port, with 4 Kintex FPGA cards running fully open PCIe endpoint, DMA engine, and UberDDR3 controller.
Accelerators based on ZTachip will be implemented on the platform

## Status

### Task 1: Raspberry Pi CM5 + 4-Lane PCIe Baseboard
Schematics & PCB finished and sent to fabrication. 

[Board description](./1-baseboard/README.md)

The next step is board bring-up and test if the PCIe endpoint works under the PCIe switch. 

### Task 2: PCIe endpoint on Kintex 7

PCIe Gen2 x1 with OpenXC7 now works on Kintex 7 70t and 480t cards!

[pcie_7x repo with build files](https://github.com/regymm/pcie_7x) 

[OpenXC7 docker build file, with specified commit fully tested](https://github.com/FPGAOL-CE/osstoolchain-docker-things/tree/master/openxc7)

### Task 3: DMA over PCIe between FPGA and RPi CM5 Module
### Task 4: Porting ZTachip to OpenXC7
### Task 5: Integrated accelerator demonstration
### Task 6: ...
### Beyond code: Documentation in N4L

## Funding

 This project received funding through [NGI0 Entrust](https://nlnet.nl/entrust), a fund established by [NLnet](https://nlnet.nl) with financial support from the European Commission's [Next Generation Internet](https://ngi.eu) program. Learn more at the [NLnet project page](https://nlnet.nl/project/PCIe-DMA-DDR3-accelerator/).

 [<img src="https://nlnet.nl/logo/banner.png" alt="NLnet foundation logo" width="20%" />](https://nlnet.nl) [<img src="https://nlnet.nl/image/logos/NGI0_tag.svg" alt="NGI Zero Logo" width="20%" />](https://nlnet.nl/entrust)
