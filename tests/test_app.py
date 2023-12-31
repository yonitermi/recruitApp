import unittest
from app import app, db
from app.models import Recruiter

class RecruiterTestCase(unittest.TestCase):

    def setUp(self):
        app.config['TESTING'] = True
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
        self.app = app.test_client()

        with app.app_context():
            db.create_all()

    def tearDown(self):
        # Drop the database
        with app.app_context():
            db.session.remove()
            db.drop_all()

    def test_index_get(self):
    # Test GET request to index route
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Recruiter Information', response.data)  # Updated content

    def test_index_post(self):
    # Test POST request to index route
        response = self.app.post('/', data=dict(
            name='John Doe',
            company='Example Inc.',
            phone='1234567890',
            email='john@example.com',
            message='Hello'
        ), follow_redirects=True)
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Thank You!', response.data)  # Updated content

        # Verify database entry
        with app.app_context():
            recruiter = Recruiter.query.filter_by(email='john@example.com').first()
            self.assertIsNotNone(recruiter)
            self.assertEqual(recruiter.name, 'John Doe')

if __name__ == '__main__':
    unittest.main()
