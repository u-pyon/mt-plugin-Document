package Document::L10N::ja;

use strict;
use warnings;

use base 'Document::L10N';
use vars qw( %Lexicon );



%Lexicon = (
# plugins/Document/lib/Document/Plugin.pm
  'Utilities for create documents.' => 'ドキュメント作成用データをダウンロードできます。',
  'Document' => 'ドキュメント',
  'Download Documents' => 'ドキュメントダウンロード',
  'Download' => 'ダウンロード',

# plugins/Document/tmpl/cms/doument_list.tmpl
  'You can download templates csv list.' => 'テンプレートのCSVファイル一覧をダウンロードできます。',
  'Templates' => 'テンプレート',
  'Download CSV' => 'CSVをダウンロード',
  '[_1]_TemplateList.csv' => '[_1]_TemplateList.csv',
  'Widget Templates' => 'ウィジェットテンプレート',
  'System Templates' => 'システムテンプレート',
  'Except widgetset or widget templates from csv.' => 'ウィジェットセットおよびウィジェットテンプレートをCSVデータに含めない場合はチェックしてください。',
  'Except system templates from csv.' => 'システムテンプレートをCSVデータに含めない場合はチェックしてください。',
  'No Widget' => 'ウィジェットを除く',
  'No System' => 'システムテンプレートを除く',

);

1;
