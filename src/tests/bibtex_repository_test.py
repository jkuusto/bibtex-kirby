from repositories.bibtex_repository import bibtex_repository
from config import app
from util import filter_bibtexs

import unittest

class TestBibtexRepository(unittest.TestCase):
    def setUp(self):
        self.repo = bibtex_repository
        self.test_data = {
            "title": "Creating bibs",
            "year": 2024
        }
        self.new_data = {
            "title": "Updating bibs",
            "year": 2023,
            "journal": "Updated Bibs",
            "author": "Serial Updater"
        }
        self.content = {
            "label": "test_bib",
            "type": "article",
            "data": self.test_data
        }
        self.new_content = {
            "label": "test2024bib",
            "type": "article",
            "data": self.new_data
        }

    def test_create_bibtex_adds_a_bibtex(self):
        with app.app_context():
            self.repo.reset_db()
            self.repo.create_bibtex(self.content)
            result = self.repo.get_bibtex_by_label("test_bib")

        self.assertEqual(result.label, "test_bib")

    def test_delete_bibtex_deletes_the_bibtex(self):
        with app.app_context():
            self.repo.reset_db()
            new_bibtex_id = self.repo.create_bibtex(self.content)
            self.repo.delete_bibtex(new_bibtex_id)
            result = self.repo.get_bibtexs()

        self.assertEqual(result, [])

    def test_bibtex_data_from_db_is_dict(self):
        with app.app_context():
            self.repo.reset_db()
            self.repo.create_bibtex(self.content)
            result = self.repo.get_bibtex_by_label("test_bib")

        bibtex = result.data

        reference_dict = {
            "title": "Creating bibs",
            "year": 2024
        }

        self.assertEqual(bibtex, reference_dict)

    def test_reset_db(self):
        with app.app_context():
            self.repo.reset_db()
            self.repo.create_bibtex(self.content)
            self.repo.reset_db()
            result = self.repo.get_bibtexs()
        
        self.assertEqual(result, [])

    def test_update_db(self):
        with app.app_context():
            self.repo.reset_db()
            new_bibtex_id = self.repo.create_bibtex(self.content)
            self.repo.update_bibtex(new_bibtex_id, self.new_content)
            result = self.repo.get_bibtex_by_label(self.new_content['label'])

        self.assertEqual(result.data['author'], "Serial Updater")

    def test_filtering_works(self):
        with app.app_context():
            self.repo.reset_db()
            self.repo.create_bibtex(self.new_content)
            result = self.repo.get_bibtexs()
    
        self.assertEqual(len(filter_bibtexs(result, "updating")), 1)
        self.assertEqual(len(filter_bibtexs(result, "ååå")), 0)

    def test_can_add_and_get_tags(self):
        with app.app_context():
            self.repo.reset_db()
            new_bibtex_id = self.repo.create_bibtex(self.content)

            self.repo.add_tag(new_bibtex_id, "dummy tag")
            self.repo.add_tag(new_bibtex_id, "computer")

            bib = self.repo.get_bibtex_by_label(self.content['label'])

        self.assertEqual(bib.tags, ["dummy tag", "computer"])