import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../domain/entities/academicien.dart';
import '../../../../injection_container.dart';

/// Ecran présentant la liste des académiciens pour le suivi médical.
class MedecinAcademyScreen extends StatefulWidget {
  const MedecinAcademyScreen({super.key});

  @override
  State<MedecinAcademyScreen> createState() => _MedecinAcademyScreenState();
}

class _MedecinAcademyScreenState extends State<MedecinAcademyScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Academicien> _academicians = [];
  bool _isLoading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadAcademicians();
  }

  Future<void> _loadAcademicians() async {
    setState(() => _isLoading = true);
    try {
      final results = await DependencyInjection.academicienRepository.getAll();
      if (mounted) {
        setState(() {
          _academicians = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _search(String query) async {
    setState(() {
      _query = query;
      _isLoading = query.isNotEmpty;
    });

    if (query.isEmpty) {
      _loadAcademicians();
      return;
    }

    try {
      final results = await DependencyInjection.academicienRepository.search(
        query,
      );
      if (mounted) {
        setState(() {
          _academicians = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: _searchController,
            onChanged: _search,
            decoration: InputDecoration(
              hintText: l10n.searchMedicalFile,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _search('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _academicians.isEmpty
              ? Center(child: Text(l10n.noPlayerFound))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _academicians.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final academician = _academicians[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        backgroundImage: academician.photoUrl.isNotEmpty
                            ? NetworkImage(academician.photoUrl)
                            : null,
                        child: academician.photoUrl.isEmpty
                            ? const Icon(Icons.person_rounded)
                            : null,
                      ),
                      title: Text(
                        '${academician.prenom} ${academician.nom}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        children: [
                          if (academician.aAllergie == true)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                size: 14,
                                color: Colors.red.shade400,
                              ),
                            ),
                          Text('${academician.taille} cm'),
                          const Text(' • '),
                          Text(
                            l10n.yearsOld(
                              _calculateAge(academician.dateNaissance),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        // TODO: Naviguer vers le détail médical
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  int _calculateAge(DateTime birthDate) {
    DateTime now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
