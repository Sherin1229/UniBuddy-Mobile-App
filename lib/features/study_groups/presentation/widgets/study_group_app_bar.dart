import 'package:flutter/material.dart';

class StudyGroupAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isMyGroupsSelected;
  final VoidCallback onStudyGroups;
  final VoidCallback onMyGroups;
  final VoidCallback onCreateGroup;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onNotificationsPressed;
  final int notificationCount;

  const StudyGroupAppBar({
    super.key,
    required this.isMyGroupsSelected,
    required this.onStudyGroups,
    required this.onMyGroups,
    required this.onCreateGroup,
    this.onProfilePressed,
    this.onNotificationsPressed,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    const brandHeaderColor = Color(0xFF3D9E8C);
    final width = MediaQuery.sizeOf(context).width;
    final brandSize = width < 900 ? 18.0 : 19.0;
    final actionFontSize = width < 900 ? 12.0 : 13.0;
    final createFontSize = width < 900 ? 12.0 : 13.0;

    return AppBar(
      backgroundColor: brandHeaderColor,
      surfaceTintColor: brandHeaderColor,
      elevation: 0,
      toolbarHeight: width < 900 ? 52 : 56,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'UniBuddy',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: brandSize,
                letterSpacing: 0.2,
              ),
            ),
            if (width >= 900) const Spacer(),
            if (width >= 900)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.transparent,
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: onStudyGroups,
                      style: TextButton.styleFrom(
                        backgroundColor: isMyGroupsSelected
                            ? Colors.transparent
                            : Colors.white.withValues(alpha: 0.18),
                        foregroundColor: isMyGroupsSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Study Groups',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: onMyGroups,
                      style: TextButton.styleFrom(
                        backgroundColor: isMyGroupsSelected
                            ? Colors.white.withValues(alpha: 0.18)
                            : Colors.transparent,
                        foregroundColor: isMyGroupsSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'My Groups',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (width >= 900)
          ElevatedButton.icon(
            onPressed: onCreateGroup,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Create Group'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: brandHeaderColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: TextStyle(fontSize: actionFontSize),
            ),
          ),
        const SizedBox(width: 8),
        Stack(
          children: [
            InkWell(
              onTap: onNotificationsPressed,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.65),
                    width: 1.5,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            if (notificationCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    notificationCount > 99 ? '99+' : '$notificationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onProfilePressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.65),
                width: 2,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.account_circle, color: Colors.white, size: 22),
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
