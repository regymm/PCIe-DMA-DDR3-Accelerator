# Pure Hardware YOLO Inference

## Idea start

This section tackles the very beginning of the project, its objective and the team structure

The project was implemented by Our-team as a part of our graduation project in our bachelor year

Our-team is a group of 6 Members

Our-team has name Electronic Aliens

Our-team proposes System that succeeds in helping drivers to automate the cruise

Our-team is supported by two supervisors

The goal of the project was to exclude software from computations and produce a pure hardware system capable of efficently assisting drivers

Excluding software enables more optimization

Excluding software enables more hands-on experience with hardware

System was to involve AI block for detecting potential objects during the cruise

Autonomous cars has example Tesla Cars

The goal of implementing the system required delivering an edge-computing pure-hardware device

System implicates the use of Hardware either FPGA or ASIC

System involves no employed software

System enables autonomous driving

System implies deployment of AI on hardware

## Accessibility

In this section, we would discuss the accessibility of the project codes

The project codes is open-source on GitHub

project codes has resource/reference github.com/m7md5303/pure-hardware-YOLO-inference

open-source enables reproduction

open-source enables receiving suggestions for improving the project

Project Repository includes detailing Readme file for its structure

Project Repository includes colab notebooks codes

Project Repository includes Verilog code for post-processing unit

Project Repository includes Systemverilog testbench for the system

## License

In this section the license associated with the project is discussed

project associated with MIT License

MIT License is an element of open-source famous licenses

MIT License enables reusability with preserving the authors rights

## Literature Review

This section discusses some of algorithms our-team explored before going through the project implementation

Our-team decides using AI algorithm for autonomous vehicles

AI algorithm deployed by Our-team on FPGA

Research conducted by Our-team for getting the most suitable AI algorithm

Convolutional Neural Networks is known for efficienct in Computer Vision Applications

Convolutional Neural Networks has abbreviation CNN

CNN used for detecting objects and classification

R-CNN has abbreviation Regional CNN

R-CNN is known for producing accurate output

R-CNN is known for high latency

After some research, Our-team figured out YOLO network would be more efficient for our application

YOLO enables low latency inference

YOLO enables satisfactory accuracy

YOLO stands for You Only Look Once

The issue was choosing specific version of YOLO, as it has many flavors and versions

The choice implies hardware-friendly implementation

This was a challenge because YOLO is more complex than CNN

## Target Hardware

In this section, the used hardware as long as who provided it to us is discussed

Our-team decides to implement the system on ZCU102

ZCU102 is available in Electronics Research Institute

Electronics Research Institute has abbreviation ERI

Electronics Research Institute enables usage of ZCU102 for Our-team

ZCU102 is known for its high capabilities

ZCU102 is known for being MPSoC

MPSoC has abbreviation Multi-Processor System-on-Chip

Our-team decides to use the PL part only of ZCU102

PL has abbreviation Programmable Logic

PL means FPGA side of the SoC

Using the PL only is because Our-team excluded any software from computations

## Block Diagram

Here, we will discuss some details about the final system block diagram

The system is consisting of two pure-hardware blocks implying no software for the whole inference

In the following lines the details would be dicussed

System consists of accelerator and post-processing block

System has source of AXI-stream data

System the source for Inference output in the form of AXI-stream

System implies only hardware modules on FPGA

## Block Diagram

AXI-Stream data represents/models input image

AXI-Stream is known for efficiency in image processing applications

AXI-Stream implies low communication overhead

AXI-Stream is used by most of Xilinx IPs

Our-team decides to use AXI-Stream as the System input and output interface

input image is a set of 416 x 416 pixels

input image represents/models the road view

input image is a set of stream of bytes packed in AXI-Stream frames

Inference output consists of 13 row_det signals and detect_valid bit

13 row_det signals represents/models 13 x 13 grid

one row_det signal represents/models 13 horizontal line of 13 x 13 grid

each bit represents/models 32 x 32 pixels

each grid predicition associated with high detect_valid

This aims for guiding the receiving block from the system to catch only the valid prediction

The detect_valid is for each single grid for protection purposes so that once the system detects a car it gives that grid result without waiting for the whole image

This approach enables more safety

This approach enables faster response

## More Details about the System

In this section, we are going to go deeper into the system details

The accelerator is for the neural network while the post-processing block is for processing the raw output of the neural network for getting the final inference results

The used YOLO model is called LPYOLO

neural network has abbreviation NN

neural network used for object-detection

neural network is called Low-Precesion You-Only-Look-Once in System

LPYOLO has abbreviation Low-Percision You-Only-Look-Once

LPYOLO is a variant of YOLO

LPYOLO replaces sigmoid with hard tanh for hardware compatibility

LPYOLO is implied-by Sefa Burak in 2022

It was built mainly for face detection

Our-team train LPYOLO to serve the cars detection purpose

used dataset is cars detection dataset was published by some user on Kaggle

Sigmoid replacement enables being more friendly to hardware deployment

accelerator means Neural network after hardware transformation

accelerator is called streamingdataflowpartition

accelerator comes before post-processing block

accelerator supplies post-processing block with raw detection bytes of the NN core computations

accelerator is generated by FINN Framework

FINN Framework generates Hardware IP for NN

FINN Framework is created by Xilinx Reasearch Lab

FINN Framework is completely open-source

FINN flow consists of 6 stages

FINN flow has resource/reference https:/medium.com/@m7md5303/finn-framework-nn-to-ip-dc88df882a5b

post-processing module is called yolo_post

yolo_post was implemented by Verilog

Verilog enables good resource control

Verilog supports higher throughput

raw detection bytes comes from accelerator

yolo_post action to take processing on raw detection bytes

third of raw detection bytes represents/models probability of class and objectness scores

NN output contains three anchor boxes

Each anchor box generates 6 bytes

The last two bytes of these 6 bytes represents/models probability of class and objectness scores

class and objectness score is represented/modelled by two bytes for each anchor box

class and objectness score determines the presence of cars when multiplied together

These scores represents probability so to get the final result, they are multiplied together

The multiplication implies no floating point operations

System consider three anchor boxes for safety purposes

If only one anchor box sensed a car whole system says there is a car

## Implementation

This section is to discuss detailed steps of implementation of the system

Jupyter Notebooks used for most of the implementation flow

Colab Cloud used for training and exporting

Colab Cloud is provisioned by Google

After training the NN, trained model from which we derive QONNX file

QONNX file represents/models quantized NN

QONNX file delivered to FINN for the transformations

transformations involves elimination floating point operations and NN layers to Hardware Conversions

## Implementation

FINN Framework enables transformations checking

transformations checking should precede/come before IP generation

Parallelism degree of the accelerator is determined by configurations decided by designer

accelerator clock frequency is determined by designer

For our system, we set the frequency to be 150 MHz

This should be sufficient for real time calculations

FINN flow implies running Jupyter Notebooks on local host

post-processing is handled by yolo_post

yolo_post involves no floating point operations

yolo_post makes use of Verilog functions for tidying the code

## Inference Results

Here, we will talk about the final results

For visulaizing the hardware results, PYNQ Jupyter Notebook was used

This implies implementing the accelerator on the PYNQ-Z2 besides the main board which is ZCU102

Testing on PYNQ-Z2 makes use of Xilinx AXI DMA for sending test images

Design on PYNQ-Z2 implies lower clock frequency because the lack in resources

Clock frequency on PYNQ-z2 has value 100 MHz

System generates high-valued bits for grids contains cars

System leads to reliable inference results

System was published by Our team in IEEE ICECS25 Proceedings

System succeeds real-rime processings

Inference-rate has value 67 FPS on ZCU102

Inference-rate has value 18 FPS on PYNQ-Z2

System proved its capability in standing out in autonomous vehicles applications

