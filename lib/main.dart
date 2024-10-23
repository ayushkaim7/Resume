import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resume/resume.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


 

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: HomePage()
      ),
    );
  }

  
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  final String linkedinUrl = 'https://www.linkedin.com/in/ayush-kaim-b02b87156/';
  final String projects = 'https://drive.google.com/drive/folders/1eTKP8TMqKwUHmahw0bKUOChB0VQ_pC_R?usp=sharing';


 Future<void> gotolinkedin() async {
  final Uri uri = Uri.parse(linkedinUrl);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $uri');
  }
}



 Future<void> gotoprojetcs() async {
  final Uri urx = Uri.parse(projects);
  if (!await launchUrl(urx)) {
    throw Exception('Could not launch $urx');
  }
}

  void gotoresume(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> const Resume()));
  }


  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2193b0), 
                Color(0xFF6dd5ed), 
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buttons(() => gotoresume(context), 'Resume'),
                const SizedBox(height: 40,),
                buttons(gotolinkedin , 'LinkedIn'),
                const SizedBox(height: 40,),
                buttons(gotoprojetcs, 'Projects')
                
              ],
            ),
          ),
        );
  }

  ElevatedButton buttons(void Function() ontap , String text) {
    return ElevatedButton(onPressed: (){
      ontap();
              }, child: Text('$text' , style: 
              
              GoogleFonts.getFont('Poppins' , textStyle: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w600
              )),),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width - 70, 55)
              ),
              
              );
  }
}
