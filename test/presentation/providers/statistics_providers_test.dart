import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:stalvi/presentation/providers/statistics_providers.dart';

void main() {
  test(
      'statisticsCurrencyProvider returns profile default currency when accountId is null',
      () async {
    final container = ProviderContainer(
      overrides: [
        defaultProfileProvider.overrideWith(
          (ref) => Future.value(
            Profile(
              id: 'p1',
              name: 'Test',
              username: 'test',
              password: '',
              defaultCurrency: 'GBP',
              createdAt: DateTime.now(),
              modifiedAt: DateTime.now(),
            ),
          ),
        ),
      ],
    );

    // Wait for the async provider to resolve
    await container.read(defaultProfileProvider.future);

    final currency = container.read(statisticsCurrencyProvider);
    expect(currency, 'GBP');
  });

  test(
      'statisticsCurrencyProvider returns account currency when accountId is not null',
      () async {
    final account = Account(
      id: 'acc1',
      userId: 'p1',
      name: 'Account',
      type: AccountType.cash,
      initialBalance: 0,
      currency: 'USD',
      color: 'blue',
      icon: 'icon',
      isDefault: true,
      isDeleted: false,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );

    final container = ProviderContainer(
      overrides: [
        accountsListProvider.overrideWith(
          (ref) => Stream.value([account]),
        ),
      ],
    );

    // Set the accountId in the filter
    container.read(statisticsFilterProvider.notifier).setAccountId('acc1');

    // Wait for the accounts provider to resolve
    await container.read(accountsListProvider.future);

    final currency = container.read(statisticsCurrencyProvider);
    expect(currency, 'USD');
  });
}
