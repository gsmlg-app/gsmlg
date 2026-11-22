import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/chat/widgets/agent_activity_panel.dart';

void main() {
  testWidgets('renders empty when no tools or sub-agents exist', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AgentActivityPanel(toolActivities: [], subAgents: []),
        ),
      ),
    );
    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('displays tools and sub-agents and toggles collapse', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AgentActivityPanel(
            isStreaming: true,
            toolActivities: [
              ChatToolActivity(
                callId: 'c1',
                toolName: 'memory_search',
                status: 'succeeded',
                resultPreview: '{"total": 2}',
                durationMs: 42,
              ),
            ],
            subAgents: [
              ChatSubAgentActivity(
                taskId: 'sub_1',
                parentRunId: 'run-1',
                childRunId: 'run_sub_1',
                workerName: 'researcher',
                goal: 'Inspect DNS records',
                status: 'running',
                depth: 1,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.textContaining('1 tool · 1 sub-agent'), findsOneWidget);
    expect(find.text('memory_search'), findsOneWidget);
    expect(find.text('researcher'), findsOneWidget);
    expect(find.text('Inspect DNS records'), findsOneWidget);

    // Collapse panel
    await tester.tap(find.byType(InkWell));
    await tester.pump();
    expect(find.text('memory_search'), findsNothing);
    expect(find.text('researcher'), findsNothing);
  });
}
