import 'package:conduit/bloc/profile_bloc/profile_bloc.dart';
import 'package:conduit/bloc/profile_bloc/profile_event.dart';
import 'package:conduit/bloc/profile_bloc/profile_state.dart';
import 'package:conduit/config/constant.dart';
import 'package:conduit/main.dart';
import 'package:conduit/model/profile_model.dart';
import 'package:conduit/ui/my_articles/my_articles_screen.dart';
import 'package:conduit/utils/AppColors.dart';
import 'package:conduit/utils/functions.dart';
import 'package:conduit/utils/image_string.dart';
import 'package:conduit/utils/message.dart';
import 'package:conduit/widget/conduitEditText_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:conduit/config/hive_store.dart';



class ProfileScreen extends StatefulWidget {
  static const profileUrl = '/profile';
  
  // Das ImagePicker-Objekt wird im Konstruktor übergeben, damit es im Test austauschbar ist
  final ImagePicker imagePicker;

  ProfileScreen({Key? key, ImagePicker? picker})
      : imagePicker = picker ?? ImagePicker(), // Wenn kein Picker übergeben wird, wird ein neuer ImagePicker erstellt
        super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? email, username, bio, image;
  TextEditingController? emailCtr, usernameCtr, bioCtr;
  TextEditingController passwordCtr = TextEditingController();
  late ProfileBloc profileBloc;
  bool isLoading = false;
  bool isNoInternet = false;
  bool isEdited = false;

  XFile? selectedImage; // Dieses Feld speichert das ausgewählte Bild als XFile-Objekt (aus dem ImagePicker)

  

  @override
  void initState() {
    profileBloc = context.read<ProfileBloc>();
    profileBloc.add(FetchProfileEvent());
    addData();
    super.initState();
  }

  addData() {
    emailCtr = TextEditingController(text: email);
    usernameCtr = TextEditingController(text: username);
    bioCtr = TextEditingController(text: bio);
    image;
  }


  // Diese Methode öffnet die Bildauswahl, damit der Benutzer ein Bild auswählen kann
  Future<void> pickImage() async {
    
    // Hier wird die Bildauswahl des Geräts geöffnet, damit der Benutzer ein Bild aus seiner Galerie auswählen kann
    final pickedFile = await widget.imagePicker.pickImage(source: ImageSource.gallery);


    // Wenn der Benutzer ein Bild ausgewählt hat, wird es im State gespeichert, um sie später hochladen zu können
    if (pickedFile != null) {
      setState(() {
        selectedImage = pickedFile;
      });
    }
  }

  // Diese Methode lädt das ausgewählte Profilbild auf den Server hoch
  Future<void> uploadProfileImage(String token) async {
  
    // Wenn kein Bild ausgewählt wurde, wird die Methode sofort beendet
    if (selectedImage == null) return;
  
    // Die API-URL zum Hochladen des Bildes wird definiert
    final uri = Uri.parse('http://localhost:8081/api/profiles/image');

    try {
          
        // Das Bild wird als Byte-Array gelesen, um es später hochzuladen
        final bytes = await selectedImage!.readAsBytes(); 
      


        // Hier wird die HTTP POST-Anfrage vorbereitet, bei der das ausgewählte Bild zusammen mit dem Authentifizierungstoken als Formular an den Server gesendet wird
        
        //-------------------------------------------------------
        
        // Das Authentifizierungstoken wird mitgeschickt
        final request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..files.add(
          
          
            http.MultipartFile.fromBytes(
              'file',
              bytes, // Das Bild wird im Anfrage-Body mitgeschickt
              filename: selectedImage!.name,
            ),
          );

        //-------------------------------------------------------

        // Die Anfrage wird gesendet
        final streamedResponse = await request.send();

        // Die Antwort wird verarbeitet
        final response = await http.Response.fromStream(streamedResponse);

        // Wenn der Upload erfolgreich war
        if (response.statusCode == 200) {
          final imageUrl = RegExp(r'"imageUrl"\s*:\s*"([^"]+)"')
              .firstMatch(response.body)
              ?.group(1); // wird die Bild-URL aus der Server-Antwort extrahiert
          if (imageUrl != null) {
            setState(() {
              image= imageUrl; // und ins Eingabefeld geschrieben
            });
          }
        } 
      
        // Wenn der Upload fehlschlägt, wird der Fehler angezeigt
        else {
          print("Web upload failed: ${response.statusCode}");
        }
    
    

    }
    catch (e) {
      print("Upload error: $e");
    }
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            automaticallyImplyLeading: false,
            centerTitle: false,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context, isEdited ? true : false);
              },
              icon: Icon(Icons.arrow_back),
            ),
            title: Text(
              "Profile",
              style: TextStyle(
                color: AppColors.white,
                fontFamily: ConduitFontFamily.robotoRegular,
              ),
            ),
          ),
          body: SafeArea(
              child: BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileLoadingState) {
                CToast.instance.showLodingLoader(context);
              } else {
                CToast.instance.dismiss();
              }
              if (state is ProfileNoInternetState) {
                CToast.instance.dismiss();
                CToast.instance.showError(context, NO_INTERNET);
              }
              if (state is ProfileErrorState) {
                print("error ${state.message}");
                return CToast.instance.showError(context, state.message);
              }
              if (state is UpdateProfileSuccessState) {
                CToast.instance.dismiss();
                // Navigator.pop(context, true);
                // Navigator.pushNamedAndRemoveUntil(context,
                //     MyArticlesScreen.myArticlesUrl, (route) => route.isFirst);
                // Navigator.popUntil(context, (route) => route.isFirst);
                // Navigator.push(
                //   context,
                //   CupertinoPageRoute(builder: (context) {
                //     return ProfileScreen();
                //   }),
                // );
              }
              if (state is UpdateProfileErrorState) {
                // CToast.instance.dismiss(context);
                print("Profile not updated, please try again later");
                CToast.instance.showToastError(
                    "Profile not updated, please try again later");
              }
              if (state is ProfileLoadedState) {
                email = state.profileList.first.user!.email;
                username = state.profileList.first.user!.username;
                bio = state.profileList.first.user!.bio;
                image = state.profileList.first.user!.image;
                addData();
                CToast.instance.dismiss();
              }
            },
            builder: (context, state) {
              return ScrollConfiguration(
                behavior: NoGlow(),
                child: SingleChildScrollView(
                  child: GestureDetector(
                    onTap: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    },
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color: AppColors.primaryColor, width: 1)),
                                
                                // Hier wird das Profilbild in einen runden Rahmen eingefügt
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  
                                  child: selectedImage != null // Hier wird geprüft, ob der Benutzer bereits ein neues Bild ausgewählt hat
                                      
                                      // Wenn ja, wird es abhängig von der Plattform angezeigt: Auf dem Web wird das Bild über den Netzwerkpfad geladen, während es auf mobilen Geräten direkt aus dem lokalen Dateisystem geladen wird
                                      ? (kIsWeb
                                          ? Image.network(selectedImage!.path, fit: BoxFit.cover)
                                          : Image.file(File(selectedImage!.path), fit: BoxFit.cover))
                                      
                                      : image != null // wenn der Benutzer noch kein neues Bild ausgewählt hat, wird geprüft, ob bereits ein Profilbild vom Server vorhanden ist

                                          // Das hochgeladene Profilbild wird mit einem Zeitstempel in der URL angezeigt, um das Browser-Caching zu umgehen
                                          ? Image.network('$image?timestamp=${DateTime.now().millisecondsSinceEpoch}', fit: BoxFit.cover)
                                          
                                          // Wenn weder ein neues Bild ausgewählt wurde noch ein altes Bild vorhanden ist, wird ein Platzhalter-Icon für das Profilbild angezeigt
                                          : Center(
                                              child: Icon(
                                                Icons.person,
                                                size: 45,
                                                color: AppColors.text_color,
                                              ),
                                            ),
                                ),



                            ),

                          // Wenn der Benutzer ein neues Bild ausgewählt hat, wird hier der Pfad des ausgewählten Bildes unter dem Profilbild angezeigt
                          if (selectedImage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                kIsWeb ? selectedImage!.name : p.basename(selectedImage!.path), // Je nach Plattform wird der Dateiname des ausgewählten Bildes angezeigt
                                key: Key('selectedImagePath'), // Ein eindeutiger Schlüssel für Test
                                style: TextStyle(fontSize: 12, color: Colors.grey), // Der Pfad wird in kleiner, grauer Schrift angezeigt
                                ),
                              ),
                            SizedBox(
                              height: 20,
                            ),


                          // Ein Button, mit dem der Benutzer ein neues Bild aus der Bildauswahl auswählen kann
                          ElevatedButton(
                            onPressed: pickImage, // Wenn der Button gedrückt wird, wird die Bildauswahl geöffnet
                            key: Key('uploadImageButton'), // Key für Test
                            child: Text("Bild auswählen"), // Text im Button
                          ),   
                          
                                                   

                            
                            SizedBox(
                              height: 20,
                            ),
                            ConduitEditText(
                              // readOnly: true,
                              controller: usernameCtr,
                              textInputType: TextInputType.text,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(15),
                                child: SvgPicture.asset(
                                  ic_profile_icon,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              hint: "Username",
                              validator: (value) {
                                if (value!.length == 0) {
                                  return "Enter username";
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            ConduitEditText(
                                controller: bioCtr,
                                textInputType: TextInputType.text,
                                minLines: 5,
                                maxLines: 5,
                                hint: "Bio"),
                            SizedBox(
                              height: 20,
                            ),
                            ConduitEditText(
                              readOnly: true,
                              controller: emailCtr,
                              textInputType: TextInputType.emailAddress,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(15),
                                child: SvgPicture.asset(
                                  ic_mail_icon,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(60),
                                FilteringTextInputFormatter.deny(" "),
                                FilteringTextInputFormatter.deny("[]"),
                                FilteringTextInputFormatter.deny("["),
                                FilteringTextInputFormatter.deny("]"),
                                FilteringTextInputFormatter.deny("^"),
                                FilteringTextInputFormatter.deny(""),
                                FilteringTextInputFormatter.deny("`"),
                                FilteringTextInputFormatter.deny("/"),
                                // FilteringTextInputFormatter.deny("\"),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9a-zA-z._@]')),
                                FilteringTextInputFormatter.deny(RegExp(r"/"))
                              ],
                              validator: (value) {
                                if (value?.trim().isEmpty ?? true) {
                                  return "Enter email address";
                                } else if (!RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$")
                                    .hasMatch(value ?? "")) {
                                  return "Enter valid email address";
                                }
                                return null;
                              },
                              hint: "Email",
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 45,
                              child: MaterialButton(
                                key: Key('saveButton'), // Key für Test, um den Button zu können
                                color: AppColors.primaryColor,
                                textColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onPressed: () async  {
                                  if (_formKey.currentState!.validate()) {
                                    FocusManager.instance.primaryFocus!
                                        .unfocus();
                                    setState(() {
                                      isEdited = true;
                                    });

                                  // Holt die gespeicherten Benutzerdaten (inklusive Authentifizierungs-Token) aus Hive
                                  final userData = await hiveStore.isExistUserAccessData();
                                  
                                  // Aus den Benutzerdaten wird das Token des zuletzt gespeicherten Nutzers ausgelesen
                                  // Dieses Token wird benötigt, um den Bild-Upload am Server zu authentifizieren
                                  final token = userData?.values.last.token ?? '';
                                  
                                  // Führt den Bild-Upload durch, bevor die Profil-Daten aktualisiert werden
                                  await uploadProfileImage(token);
                                    
                                    profileBloc.add(
                                      UpdateProfileEvent(
                                        profileModel: ProfileModel(
                                          user: User(
                                              username:
                                                  usernameCtr!.text.toString(),
                                              email: emailCtr!.text.toString(),
                                              bio: bioCtr!.text.toString(),
                                              image: image ?? ''),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontFamily: ConduitFontFamily.robotoRegular,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            )
                            // Padding(
                            //   padding: EdgeInsets.only(top: 25),
                            //   child: SizedBox(
                            //     width: 320,
                            //     height: 45,
                            //     child: MaterialButton(
                            //       textColor: AppColors.white,
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(10),
                            //         side: BorderSide(color: Colors.red[400]!),
                            //       ),
                            //       onPressed: () {
                            //         FocusManager.instance.primaryFocus!.unfocus();
                            //         setState(() {
                            //           onLogout();
                            //         });
                            //       },
                            //       child: Text(
                            //         'Logout',
                            //         style: TextStyle(color: Colors.red[400]),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          )),
        ),
      ),
    );
  }
}
// for hivedata show 
// ValueListenableBuilder(
//             valueListenable:
//                 Hive.box<UserAccessData>(hiveStore.userDetailKey).listenable(),
//             builder: (BuildContext context, dynamic box, Widget? child) {
//               UserAccessData? detail = box.get(hiveStore.userId);
//               return Container();
//             },
//  ),