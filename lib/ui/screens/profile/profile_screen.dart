import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common/app_bar.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/loading_overlay.dart';
import '../../../constants/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();

    // Fetch profile data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AuthProvider>().fetchProfile();
      _updateControllers();
    });
  }

  void _updateControllers() {
    final profile = context.read<AuthProvider>().profile;
    if (profile != null) {
      setState(() {
        _usernameController.text = profile.username;
        _emailController.text = profile.email;
        _firstNameController.text = profile.firstName ?? '';
        _lastNameController.text = profile.lastName ?? '';
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateControllers();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        setState(() => _isLoading = true);
        await context.read<AuthProvider>().logout();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error logging out: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;
    if (profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Profile',
          showBackButton: true,
          hideProfileIcon: true,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: AppColors.white,
              ),
              onPressed: _handleLogout,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.md),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildProfileImage(profile),
                const SizedBox(height: Dimensions.lg),
                _buildProfileFields(),
                const SizedBox(height: Dimensions.lg),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(user) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: user.imageUrl != null
              ? NetworkImage("http://10.0.2.2:8000${user.imageUrl}")
              : null,
          child: user.imageUrl == null
              ? const Icon(Icons.person, size: 60, color: AppColors.grey)
              : null,
        ),
        if (_isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: AppColors.white),
                onPressed: _pickImage,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileFields() {
    return Column(
      children: [
        CustomTextField(
          controller: _usernameController,
          labelText: 'Username',
          enabled: _isEditing,
          prefixIcon: Icons.person_outline,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Username is required' : null,
        ),
        const SizedBox(height: Dimensions.md),
        CustomTextField(
          controller: _emailController,
          labelText: 'Email',
          enabled: _isEditing,
          prefixIcon: Icons.email_outlined,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Email is required' : null,
        ),
        const SizedBox(height: Dimensions.md),
        CustomTextField(
          controller: _firstNameController,
          labelText: 'First Name',
          enabled: _isEditing,
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: Dimensions.md),
        CustomTextField(
          controller: _lastNameController,
          labelText: 'Last Name',
          enabled: _isEditing,
          prefixIcon: Icons.badge_outlined,
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        if (_isEditing) ...[
          Expanded(
            child: CustomButton(
              text: 'Cancel',
              onPressed: () => setState(() => _isEditing = false),
              isOutlined: true,
            ),
          ),
          const SizedBox(width: Dimensions.md),
          Expanded(
            child: CustomButton(
              text: 'Save',
              onPressed: _updateProfile,
            ),
          ),
        ] else
          Expanded(
            child: CustomButton(
              text: 'Edit Profile',
              onPressed: () => setState(() => _isEditing = true),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isLoading = true);
        await context.read<AuthProvider>().updateProfileImage(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      print('Updating profile with:');
      print({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'firstName': firstName,
        'lastName': lastName,
      });

      await context.read<AuthProvider>().updateProfile(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            firstName: firstName,
            lastName: lastName,
          );

      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      print('Profile update error:');
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
