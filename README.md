![ECTsim](https://ectsim.ire.pw.edu.pl/images/logo.png)

MATLAB toolbox for numerical modeling and image reconstruction in electrical tomography developed at Warsaw University of Technology

## Key Authors
- Dr. Damian Wanta
- Prof. Waldemar T. Smolik
- Dr. Jacek Kryszyn

### Additional Contributors
- Mateusz Stępniewski
- Oliwia Makowiecka
- Aleksandra Kot

## Citing ECTsim
If you use ECTsim in your research, please cite the following papers:

1. D. Wanta, W. T. Smolik, J. Kryszyn, P. Wróblewski, M. Midura, "A Finite Volume Method using a Quadtree Non-Uniform Structured Mesh for Modeling in Electrical Capacitance Tomography," Proceedings of the National Academy of Sciences, India Section A: Physical Sciences, 92, 443-452, 2021. DOI: [10.1007/s40010-021-00748-7](https://doi.org/10.1007/s40010-021-00748-7)
2. D. Wanta, W. T. Smolik, J. Kryszyn, M. Midura, P. Wróblewski, "Image reconstruction using Z-axis spatio-temporal sampling in 3D electrical capacitance tomography," Measurement Science & Technology, 33(11), 2022. DOI: [10.1088/1361-6501/ac8220](https://doi.org/10.1088/1361-6501/ac8220)
3. Mikhail Ivanenko, Waldemar T. Smolik, Damian Wanta, Mateusz Midura, Przemysław Wróblewski, Xiaohan Hou, Xiaoheng Yan, "Image Reconstruction Using Supervised Learning in Wearable Electrical Impedance Tomography of the Thorax," Sensors 23(18):7774, 2023. DOI: [10.3390/s23187774](https://doi.org/10.3390/s23187774)

## Features
ECTsim utilizes the Finite Volume Method for simulations with a quadtree and octree mesh refinement for 2D and 3D models, respectively. The toolbox includes four fundamental image reconstruction algorithms: LBP, PINV, Landweber, and a semi-linear implementation of the Levenberg-Marquardt algorithm.

Included are example files `example_2D` and `example_3D` that demonstrate how to prepare a model in our software, simulate the distribution of electromagnetic fields, perform complex impedance measurements, and conduct image reconstructions using sensitivity matrices.

## Advanced Visualization
The toolbox offers advanced methods for presenting both 2D and 3D data, supporting features like windowing, MPR, surf, and slice visualizations.

## Collaboration and Contact
We are open to collaborations. If you are interested in working with us or have any inquiries, please contact us at:
- damian.wanta@pw.edu.pl
- waldemar.smolik@pw.edu.pl

For more information, visit our project website: [ECTsim Project](https://ectsim.ire.pw.edu.pl/)
