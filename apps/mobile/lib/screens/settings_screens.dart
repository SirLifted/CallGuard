import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(children: const [
        ListTile(leading: Icon(Icons.person), title: Text('Display name'), subtitle: Text('You')),
        ListTile(leading: Icon(Icons.email), title: Text('Email'), subtitle: Text('you@example.com')),
        ListTile(leading: Icon(Icons.logout), title: Text('Log out')),
      ]),
    );
  }
}

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});
  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _discoverByPhone = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(children: [
        SwitchListTile(
          value: _discoverByPhone,
          onChanged: (v) => setState(() => _discoverByPhone = v),
          title: const Text('Discoverable by phone/email'),
          subtitle: const Text('Off: only people you share your ID with can find you'),
        ),
        for (final option in const ['24 hours', '7 days', '30 days', '90 days'])
          ListTile(
            title: Text(option),
            trailing: option == '7 days' ? const Icon(Icons.check, color: Color(0xFF1A73E8)) : null,
          ),
        const ListTile(title: Text('Custom / manual'), trailing: Icon(Icons.chevron_right)),
      ]),
    );
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _calls = true, _rec = true, _extend = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(children: [
        SwitchListTile(value: _calls, onChanged: (v) => setState(() => _calls = v), title: const Text('Incoming calls')),
        SwitchListTile(
            value: _rec, onChanged: (v) => setState(() => _rec = v), title: const Text('Recording requests and results')),
        SwitchListTile(value: _extend, onChanged: (v) => setState(() => _extend = v), title: const Text('Extension requests')),
        const ListTile(title: Text('Same wording on Android and iOS — nothing extra appears.')),
      ]),
    );
  }
}

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(children: const [
        ListTile(leading: Icon(Icons.phonelink_lock), title: Text('Sessions'), subtitle: Text('This phone · log out other devices')),
        ListTile(leading: Icon(Icons.vpn_key), title: Text('Passkeys / 2FA'), subtitle: Text('Not available yet')),
        ListTile(leading: Icon(Icons.delete_forever), title: Text('Delete account'), subtitle: Text('Removes videos and profile; log entries stay per policy')),
      ]),
    );
  }
}

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blocked users')),
      body: const Center(child: Text('No blocked users.', style: TextStyle(fontSize: 14))),
    );
  }
}

class ReportUserScreen extends StatelessWidget {
  const ReportUserScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report user')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          TextField(maxLines: 4, decoration: InputDecoration(hintText: 'What happened?', border: OutlineInputBorder())),
          SizedBox(height: 12),
          ElevatedButton(onPressed: null, child: Text('Send report')),
        ]),
      ),    );
  }
}

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(children: const [
        ListTile(title: Text('Name'), subtitle: Text('You')),
        ListTile(title: Text('Email'), subtitle: Text('you@example.com')),
        ListTile(title: Text('Help & support'), trailing: Icon(Icons.chevron_right)),
      ]),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & support')),
      body: ListView(children: const [
        ListTile(title: Text('How recording permission works'), subtitle: Text('Ask → approve → record → withdraw anytime')),
        ListTile(title: Text('Why did my link expire?'), subtitle: Text('Play links live 5 minutes and are bound to you')),
        ListTile(title: Text('Report a problem'), subtitle: Text('Sends logs only — never video without permission')),
      ]),
    );
  }
}

class SettingsHubScreen extends StatelessWidget {
  const SettingsHubScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: [
        ListTile(leading: const Icon(Icons.lock), title: const Text('Privacy'), onTap: () => Navigator.pushNamed(context, '/settings/privacy')),
        ListTile(leading: const Icon(Icons.notifications), title: const Text('Notifications'), onTap: () => Navigator.pushNamed(context, '/settings/notifications')),
        ListTile(leading: const Icon(Icons.security), title: const Text('Security'), onTap: () => Navigator.pushNamed(context, '/settings/security')),
        ListTile(leading: const Icon(Icons.block), title: const Text('Blocked users'), onTap: () => Navigator.pushNamed(context, '/settings/blocked')),
        ListTile(leading: const Icon(Icons.flag), title: const Text('Report user'), onTap: () => Navigator.pushNamed(context, '/settings/report')),
        ListTile(
          leading: const Icon(Icons.manage_accounts),
          title: const Text('Account'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/settings/account'),
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Help & support'),
          onTap: () => Navigator.pushNamed(context, '/help'),
        ),
      ]),
    );
  }
}
