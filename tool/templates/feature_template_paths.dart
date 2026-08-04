const featureRepositoryContractTemplate =
    'tool/templates/feature/data/repositories/_template.repository.dart';
const featureRepositoryImplementationTemplate =
    'tool/templates/feature/data/repositories/_template.repository_impl.dart';
const featurePageTemplate =
    'tool/templates/feature/presentation/pages/_template.page.dart';
const featurePageViewWidgetTemplate =
    'tool/templates/feature/presentation/pages/widgets/'
    '_template_view.widget.dart';
const featureBlocTemplate =
    'tool/templates/feature/presentation/pages/bloc/_template.bloc.dart';
const featureBlocEventTemplate =
    'tool/templates/feature/presentation/pages/bloc/_template.event.dart';
const featureBlocStateTemplate =
    'tool/templates/feature/presentation/pages/bloc/_template.state.dart';

const featureProductionTemplatePaths = <String>[
  featureRepositoryContractTemplate,
  featureRepositoryImplementationTemplate,
  featurePageTemplate,
  featurePageViewWidgetTemplate,
  featureBlocTemplate,
  featureBlocEventTemplate,
  featureBlocStateTemplate,
];

const featureTestReferenceTemplatePaths = <String>[
  'tool/templates/feature/tests/presentation/_template.bloc_test.dart',
  'tool/templates/feature/tests/data/_template.repository_impl_test.dart',
];
