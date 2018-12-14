#
# Makefile for PO merging and MO generation. More info in the README.
#
# make all-mo (default) - generate MO files
# make check - check translations using translate-tool
# make tx-update - download and merge translations from Transifex
# make clean - clean everything
#
DOMAIN = hammer-cli-foreman
VERSION = $(shell bundle exec ruby -C ../ -e 'require "rubygems"; spec = Gem::Specification::load("./hammer_cli_foreman.gemspec"); puts spec.version')
MAIN_MAKEFILE = $(shell bundle exec ruby -C ../ -e 'require "hammer_cli"; puts HammerCLI::I18n.main_makefile')

include $(MAIN_MAKEFILE)
