import 'package:events_app_mobile/bloc/auth/auth_bloc.dart' as auth_bloc;
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/user.dart';
import 'package:events_app_mobile/screens/main_screen.dart';
import 'package:events_app_mobile/widgets/app_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _onSignOut() {
    context.read<auth_bloc.AuthBloc>().add(auth_bloc.SignOutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<auth_bloc.AuthBloc, auth_bloc.AuthState>(
      listener: (context, state) {
        if (state is auth_bloc.UnAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      },
      builder: (BuildContext context, auth_bloc.AuthState state) {
        double screenWidth = MediaQuery.of(context).size.width;
        double imageWidth = 200;
        double imageHeight = 200;
        double imageLeft = screenWidth / 2 - imageWidth / 2;

        User? user = state.user;

        String? firstNameFirstLetter = user?.firstName.characters.first;
        String? lastNameFirstLetter = user?.lastName.characters.first;
        String initials = '$firstNameFirstLetter$lastNameFirstLetter';

        Widget deleteImageButton = user?.image == null
            ? const SizedBox()
            : Positioned(
                left: 10,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset:
                            const Offset(0, 0), // changes position of shadow
                      ),
                    ],
                  ),
                  child: IconButton.filled(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                  ),
                ),
              );

        return Column(children: [
          Stack(
            children: [
              Image.asset('lib/images/profile-background.png'),
              Positioned(
                bottom: 20,
                left: imageLeft,
                child: Stack(
                  children: [
                    Container(
                        width: imageWidth,
                        height: imageHeight,
                        decoration: BoxDecoration(
                          color: LightThemeColors.primary,
                          borderRadius: BorderRadius.circular(200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontSize: 50,
                              color: LightThemeColors.white,
                            ),
                          ),
                        )),
                    deleteImageButton,
                    Positioned(
                      right: 10,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset: const Offset(
                                  0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: IconButton.filled(
                          onPressed: () {},
                          icon: const Icon(Icons.edit),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppButton(text: 'Sign Out', onPressed: _onSignOut),
        ]);
      },
    );
  }
}
