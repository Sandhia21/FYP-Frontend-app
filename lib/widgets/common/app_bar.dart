import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/constants/constants.dart';
import 'package:app/providers/auth_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Function(String)? onSearchChanged;
  final bool showSearch;
  final bool hideProfileIcon;
  final bool centerTitle;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.onSearchChanged,
    this.showSearch = false,
    this.hideProfileIcon = false,
    this.centerTitle = false,
    this.automaticallyImplyLeading = true,
  }) : super(key: key);

  bool get _isHome => !showBackButton;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final baseUrl = 'http://10.0.2.2:8000/';

    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (automaticallyImplyLeading && canPop && showBackButton)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.white,
                    onPressed: () => Navigator.pop(context),
                  )
                else if (user?.imageUrl != null)
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        baseUrl + user!.imageUrl!,
                      ),
                      onBackgroundImageError: (_, __) {
                        // Using errorBuilder pattern instead
                        return;
                      },
                      child: user.imageUrl == null
                          ? const Image(
                              image: AssetImage(
                                  'assets/icons/default_profile.png'),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: (automaticallyImplyLeading &&
                              canPop &&
                              showBackButton)
                          ? 0
                          : 16,
                    ),
                    child: Column(
                      crossAxisAlignment: centerTitle
                          ? CrossAxisAlignment.center
                          : (automaticallyImplyLeading &&
                                  canPop &&
                                  showBackButton)
                              ? CrossAxisAlignment.center
                              : CrossAxisAlignment.start,
                      children: [
                        if (_isHome && user != null)
                          Text(
                            'Hello ${user.username}',
                            style: TextStyles.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                        Text(
                          _isHome ? 'Welcome back!' : title,
                          style: TextStyles.h2.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ...(actions ??
                    [
                      if (user != null &&
                          authProvider.profile?.role == 'student')
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          color: AppColors.white,
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/notifications',
                          ),
                        ),
                      if (!hideProfileIcon)
                        IconButton(
                          icon: const Icon(Icons.person_outline),
                          color: AppColors.white,
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/profile',
                          ),
                        ),
                    ]),
              ],
            ),
          ),
          if (showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _SearchBar(onSearchChanged: onSearchChanged),
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(showSearch
      ? 160
      : showBackButton
          ? 100
          : 120);
}

class _SearchBar extends StatelessWidget {
  final Function(String)? onSearchChanged;

  const _SearchBar({
    Key? key,
    this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search courses...',
          hintStyle: TextStyles.bodySmall.copyWith(
            color: AppColors.grey,
          ),
          suffixIcon: const Icon(Icons.search, color: AppColors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
