import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/data/providers.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/provider_tile.dart';
import '../widgets/slip_card.dart';
import 'lookup_screen.dart';
import 'scan_screen.dart';
import 'viewer_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = Strings(Localizations.localeOf(context).languageCode);
    final settings = ref.watch(settingsProvider);
    final bills = ref.watch(savedBillsProvider);
    final grouped = providersByKind();
    final checkKey = GlobalKey();

    void openLookup(BillProvider p, {String? initialNumber}) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LookupScreen(provider: p, initialNumber: initialNumber),
        ),
      );
    }

    Future<void> openScan() async {
      final result = await Navigator.of(context).push<ScanResult>(
        MaterialPageRoute(builder: (_) => const ScanScreen()),
      );
      if (result == null || !context.mounted) return;
      final provider = providerById(result.providerId);
      if (provider == null) return;
      openLookup(provider, initialNumber: result.number);
    }

    final kindMeta = [
      (UtilityKind.electricity, strings.kindElectricity),
      (UtilityKind.gas, strings.kindGas),
      (UtilityKind.telecom, strings.kindTelecom),
      (UtilityKind.water, strings.kindWater),
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openScan,
        icon: const Icon(Icons.qr_code_scanner),
        label: Text(strings.scanBill),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            // ---- Header: app name + language pill ----
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings.appName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontFamily: 'Sora'),
                  ),
                ),
                LanguagePill(
                  lang: settings.lang,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setLang(v),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ---- Hero ----
            Text(strings.heroTitle,
                style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            Text(
              strings.heroSub,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppColors.of(Theme.of(context).brightness).muted),
            ),

            // ---- Your bills ----
            SectionHeader(title: strings.yourBills),
            if (bills.isEmpty)
              _EmptyBillsCard(
                onCheck: () => Scrollable.ensureVisible(
                  checkKey.currentContext!,
                  duration: const Duration(milliseconds: 400),
                ),
              )
            else
              for (final bill in bills)
                Builder(builder: (context) {
                  final provider = providerById(bill.providerId);
                  if (provider == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SlipCard(
                      bill: bill,
                      provider: provider,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ViewerScreen(
                            provider: provider,
                            reference: bill.reference,
                          ),
                        ),
                      ),
                      onTogglePaid: () => ref
                          .read(savedBillsProvider.notifier)
                          .togglePaid(bill.id),
                    ),
                  );
                }),

            // ---- Check a bill ----
            SectionHeader(
              key: checkKey,
              title: strings.checkBill,
            ),
            for (final (kind, label) in kindMeta) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                child: Row(
                  children: [
                    Icon(kindIcon(kind),
                        size: 18,
                        color: AppColors.of(Theme.of(context).brightness).muted),
                    const SizedBox(width: 8),
                    Text(label,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: AppColors.of(
                                    Theme.of(context).brightness)
                                .muted)),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 76,
                ),
                itemCount: grouped[kind]!.length,
                itemBuilder: (context, i) {
                  final p = grouped[kind]![i];
                  return ProviderTile(
                    provider: p,
                    onTap: () => openLookup(p),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyBillsCard extends ConsumerWidget {
  const _EmptyBillsCard({required this.onCheck});

  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = Strings(Localizations.localeOf(context).languageCode);
    final colors = AppColors.of(Theme.of(context).brightness);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.line, style: BorderStyle.solid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.brandSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.receipt_long, color: colors.brand),
          ),
          const SizedBox(height: 12),
          Text(strings.emptyBillsTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(strings.emptyBillsBody,
              style:
                  theme.textTheme.bodyMedium!.copyWith(color: colors.muted)),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onCheck,
            child: Text(strings.emptyBillsCta),
          ),
        ],
      ),
    );
  }
}
