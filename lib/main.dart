import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Prediction App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: JobPredictionPage(),
    );
  }
}

class JobPredictionPage extends StatefulWidget {
  @override
  _JobPredictionPageState createState() => _JobPredictionPageState();
}

class _JobPredictionPageState extends State<JobPredictionPage> {
  Interpreter? _interpreter;
  List<String> _educationOptions = [
    'PhD',
    "Master's",
    "Bachelor's",
    "WsPhD",
  ];
  List<String> _interestsOptions = [
    'Programming',
    'Artificial Intelligence',
    'Networking',
  ];
  List<String> _skillsOptions = [
    'Java',
    'Python',
    'Machine Learning',
    'Data Analysis',
    'JavaScript',
    'Network Security',
    'C++',
    'R',
    'Cisco Certified Network Associate (CCNA)',
  ];
  List<String> _certificationsOptions = [
    'Oracle Certified Professional Java SE 11 Developer',
    'Microsoft Certified: Azure Developer Associate',
    'Coursera Machine Learning Specialization',
    'IBM Data Science Professional Certificate',
    'React Developer Nanodegree',
    'Cisco Certified Network Associate (CCNA)',
    'Microsoft Certified: Azure Solutions Developer',
    'AWS Certified Solutions Architect - Associate',
    'Deep Learning Specialization on Coursera',
    'DataCamp Data Scientist with R Career Track',
    'CCNP Routing and Switching',
    'Front-End Web Developer Nanodegree',
    'Oracle Certified Master Java SE 11 Developer',
    'Machine Learning by Stanford University on Coursera',
    'Coursera Data Science Specialization',
    'Python Institute PCAP Certification',
  ];
  List<String> _predictedJobs = [
    'Software Developer',
    'Software Engineer',
    'Network Engineer',
    'Data Scientist',
    'Software Architect',
    'Machine Learning Engineer',
  ];
  String _selectedEducation = "PhD";
  String _selectedInterests = "Programming";
  String _selectedSkills = "Java";
  String _selectedCertifications =
      "Oracle Certified Professional Java SE 11 Developer";
  String _predictedJob = '';

  @override
  void initState() {
    super.initState();
    _loadModel().then((result) {
      if (result) {
        print("Model loaded successfully.");
      } else {
        print("Model loading failed.");
      }
    });
  }

  Future<bool> _loadModel() async {
    try {
      final interpreterOptions = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset(
          'C:/apps/csm1/android/assets/job.tflite',
          options: interpreterOptions);
      _interpreter!.allocateTensors();
      return true;
    } catch (e) {
      // Handle model loading errors and log them
      print("Error loading model: $e");
      return false;
    }
  }

  void _resetPredictions() {
    setState(() {
      _predictedJob = '';
    });
  }

  void _predictJob() {
    if (_interpreter == null) {
      // Model not loaded, do not proceed with inference
      print("Model not loaded. Cannot perform inference.");
      return;
    }

    try {
      // Ensure that the input tensor shape matches the model expectations [1, 32]
      var inputShape = _interpreter!.getInputTensor(0).shape;
      if (inputShape[0] != 1 || inputShape[1] != 33) {
        print("Input tensor shape does not match model expectations [1, 33].");
        _loadModel(); // Reload the model if the shape doesn't match
        return;
      }

      // Encode input features using one-hot encoding
      List<double> inputs = List.filled(33, 0.0);
      inputs[_educationOptions.indexOf(_selectedEducation)] = 1.0;
      inputs[_interestsOptions.indexOf(_selectedInterests)] = 1.0;
      inputs[_skillsOptions.indexOf(_selectedSkills)] = 1.0;
      inputs[_certificationsOptions.indexOf(_selectedCertifications)] = 1.0;

      // Create an output tensor with the expected shape [1, 6]
      var outputs = List.filled(1 * 6, 0.0).reshape([1, 6]);

      // Run inference
      _interpreter!.run(inputs, outputs);

      // Find the predicted job label
      int predictedIndex =
      outputs[0].indexOf(outputs[0].reduce((double a, double b) => a > b ? a : b));
      setState(() {
        _predictedJob = _predictedJobs[predictedIndex];
      });

      // Print the input and output tensors
      print("Input: $inputs");
      print("Output: ${outputs[0]}"); // Output should be a list of 6 values
    } catch (e) {
      // Handle inference errors and log them for debugging
      print("Error during inference: $e");
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Prediction App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedEducation,
              items: _educationOptions.map<DropdownMenuItem<String>>(
                    (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
              ).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEducation = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Education',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedInterests,
              items: _interestsOptions.map<DropdownMenuItem<String>>(
                    (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
              ).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedInterests = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Interests',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSkills,
              items: _skillsOptions.map<DropdownMenuItem<String>>(
                    (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
              ).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSkills = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Skills',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: 400, // Set the desired width for the dropdown
              child: DropdownButtonFormField<String>(
                value: _selectedCertifications,
                items: _certificationsOptions.map<DropdownMenuItem<String>>(
                      (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCertifications = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Certifications',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                isExpanded: true,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _predictJob,
              child: Text('Predict Job'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetPredictions,
              child: Text('Reset Predictions'),
            ),
            SizedBox(height: 16),
            Text(
              'Predicted Job: $_predictedJob',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
