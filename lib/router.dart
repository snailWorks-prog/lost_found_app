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

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // Вне Shell: экран авторизации
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Постоянные вкладки через StatefulShellRoute
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        // Вкладка 1: Доска объявлений и её подмаршруты
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/board',
              builder: (context, state) => const BoardScreen(),
              routes: [
                GoRoute(
                  path: 'new', // Полный путь: /board/new (перед :id!)
                  builder: (context, state) => const NewItemScreen(),
                ),
                GoRoute(
                  path: ':id', // Полный путь: /board/:id
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return ItemDetailsScreen(itemId: id);
                  },
                  routes: [
                    GoRoute(
                      path: 'claim', // Полный путь: /board/:id/claim
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

        // Вкладка 2: Личная активность и чаты
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my-items',
              builder: (context, state) => const MyItemsScreen(),
              routes: [
                GoRoute(
                  path: 'chat/:id', // Полный путь: /my-items/chat/:id
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return ChatScreen(claimId: id);
                  },
                ),
              ],
            ),
          ],
        ),

        // Вкладка 3: Профиль пользователя
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