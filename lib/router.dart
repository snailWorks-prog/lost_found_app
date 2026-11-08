import 'package:go_router/go_router.dart';
import 'screens/board_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/claim_form_screen.dart';
import 'screens/item_details_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_items_screen.dart';
import 'screens/new_item_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/app_shell.dart';

late final GoRouter appRouter;

GoRouter createAppRouter({required bool loggedIn}) {
  return GoRouter(
    initialLocation: loggedIn ? '/board' : '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/board',
                builder: (context, state) => const BoardScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const NewItemScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ItemDetailsScreen(itemId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'claim',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return ClaimFormScreen(itemId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-items',
                builder: (context, state) => const MyItemsScreen(),
                routes: [
                  GoRoute(
                    path: 'chat/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ChatScreen(claimId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
