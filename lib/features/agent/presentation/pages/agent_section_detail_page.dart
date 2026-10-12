import 'package:flutter/material.dart';

import 'agent_dashboard_page.dart';
import 'agent_profile_page.dart';

/// Compatibility router for Agent Center sections.
/// Only sections backed by the Laravel Agent endpoints are kept here.
class AgentSectionDetailPage extends StatelessWidget {
  const AgentSectionDetailPage({super.key, required this.section});

  final AgentToolSection section;

  @override
  Widget build(BuildContext context) {
    switch (section) {
      case AgentToolSection.dashboard:
      case AgentToolSection.propertyManagement:
      case AgentToolSection.agencyPois:
        return const AgentDashboardPage();
      case AgentToolSection.profileVerification:
        return const AgentProfilePage();
    }
  }
}

enum AgentToolSection {
  dashboard,
  propertyManagement,
  agencyPois,
  profileVerification,
}

extension AgentToolSectionName on AgentToolSection {
  String get name {
    switch (this) {
      case AgentToolSection.dashboard:
        return 'My Dashboard';
      case AgentToolSection.propertyManagement:
        return 'Property Management';
      case AgentToolSection.agencyPois:
        return 'Agency POIs';
      case AgentToolSection.profileVerification:
        return 'Profile & Verification';
    }
  }
}
