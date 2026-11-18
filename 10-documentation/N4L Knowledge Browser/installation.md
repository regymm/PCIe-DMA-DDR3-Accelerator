# Installation Procedures for KViz

After cloning the project through:
```bash
git clone https://github.com/regymm/PCIe-DMA-DDR3-Accelerator.git
```

Go to the browser source code directory:
```bash
cd "PCIe-DMA-DDR3-Accelerator/10-documentation/N4L Knowledge Browser/n4lkviz"
```

If it is your first time ever with running a React app created with Vite, you need to install<a href='https://nodejs.org/en/download'>Node.js</a> firstly

You can run these directly if using Ubuntu 22.04:

```bash
sudo apt update
sudo apt install nodejs npm
```

Now you need to install the necessary packages if it is your first time with using KViz:
```bash
npm install
```

After all things are ready, you can easily run :
```bash
npm run dev
```
whenever you want to surf through your knowledge.

This command will display a local http link that you should visit for browsing the knowledge...

For feeding the database, please check the <a href='https://github.com/regymm/PCIe-DMA-DDR3-Accelerator/tree/main/10-documentation/N4L%20Knowledge%20Browser'>project  ReadMe </a> for steps on how to use the project python compiler.
