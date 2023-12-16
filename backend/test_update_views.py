import unittest
import os
from unittest.mock import patch, Mock, MagicMock

from update_views import Entity

class TestEntity(unittest.TestCase):

    @patch.object(Entity, "__init__", Mock(return_value=None))
    def test_update_views(self):
        mock_entity = MagicMock()
        mock_entity.entity.return_value = {
            "PartitionKey": "testing",
            "RowKey": "home",
            "views": 0
        }

        data = Entity()
        data.entity = mock_entity.entity.return_value
        data.update_views()

        self.assertEqual(data.entity["views"], 1)

if __name__ == '__main__':
    unittest.main()