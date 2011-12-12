Gem::Specification.new do |s|
  s.name = 'tb'
  s.version = '0.1'
  s.date = '2011-12-01'
  s.author = 'Tanaka Akira'
  s.email = 'akr@fsij.org'
  s.files = %w[
    README
    bin/tb
    lib/tb.rb
    lib/tb/basic.rb
    lib/tb/catreader.rb
    lib/tb/cmd_cat.rb
    lib/tb/cmd_crop.rb
    lib/tb/cmd_cross.rb
    lib/tb/cmd_csv.rb
    lib/tb/cmd_grep.rb
    lib/tb/cmd_group.rb
    lib/tb/cmd_gsub.rb
    lib/tb/cmd_help.rb
    lib/tb/cmd_join.rb
    lib/tb/cmd_json.rb
    lib/tb/cmd_mheader.rb
    lib/tb/cmd_newfield.rb
    lib/tb/cmd_pp.rb
    lib/tb/cmd_rename.rb
    lib/tb/cmd_select.rb
    lib/tb/cmd_shape.rb
    lib/tb/cmd_sort.rb
    lib/tb/cmd_tsv.rb
    lib/tb/cmd_yaml.rb
    lib/tb/cmdmain.rb
    lib/tb/cmdtop.rb
    lib/tb/cmdutil.rb
    lib/tb/csv.rb
    lib/tb/enumerable.rb
    lib/tb/fieldset.rb
    lib/tb/reader.rb
    lib/tb/record.rb
    lib/tb/search.rb
    lib/tb/tsv.rb
    sample/excel2csv
    sample/langs.csv
    sample/poi-xls2csv.rb
    sample/poi-xls2csv.sh
    test-all-cov.rb
    test-all.rb
  ]
  s.test_files = %w[
    test/test_basic.rb
    test/test_catreader.rb
    test/test_cmd_cat.rb
    test/test_cmd_crop.rb
    test/test_cmd_cross.rb
    test/test_cmd_csv.rb
    test/test_cmd_grep.rb
    test/test_cmd_group.rb
    test/test_cmd_gsub.rb
    test/test_cmd_help.rb
    test/test_cmd_join.rb
    test/test_cmd_json.rb
    test/test_cmd_mheader.rb
    test/test_cmd_newfield.rb
    test/test_cmd_pp.rb
    test/test_cmd_rename.rb
    test/test_cmd_select.rb
    test/test_cmd_shape.rb
    test/test_cmd_sort.rb
    test/test_cmd_tsv.rb
    test/test_cmd_yaml.rb
    test/test_cmdtty.rb
    test/test_csv.rb
    test/test_enumerable.rb
    test/test_fieldset.rb
    test/test_reader.rb
    test/test_record.rb
    test/test_search.rb
    test/test_tsv.rb
  ]
  s.has_rdoc = true
  s.homepage = 'https://github.com/akr/tb'
  s.require_path = 'lib'
  s.executables << 'tb'
  s.summary = 'manipulation tool for table: CSV, TSV, etc.'
  s.description = <<'End'
manipulation tool for table: CSV, TSV, etc.
End
end
