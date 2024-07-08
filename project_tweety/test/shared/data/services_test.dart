import 'package:project_tweety/shared/data/services.dart';
import 'package:test/test.dart';

void main() {
  group('Services', () {
    test('postData sends a POST request and handles a successful response',
        () async {
      final services = Services();

      final response = await services.postData(
        '/posts',
        headers: {'Content-Type': 'application/json'},
        body: {"title": "Updated Title", "body": "Updated Body", "userId": 1},
      );

      expect(response, {
        "title": "Updated Title",
        "body": "Updated Body",
        "userId": 1,
        "id": 101
      },);
    });

    test('getData sends a GET request and handles a successful response',
        () async {
      final services = Services();

      final response = await services.getData('/posts');
      expect(response[0], {
        'userId': 1,
        'id': 1,
        'title':
            'sunt aut facere repellat provident occaecati excepturi optio reprehenderit',
        'body': 'quia et suscipit\n'
            'suscipit recusandae consequuntur expedita et cum\n'
            'reprehenderit molestiae ut ut quas totam\n'
            'nostrum rerum est autem sunt rem eveniet architecto'
      });
    });

    test('getData requests a single post and handles a successful response',
            () async {
          final services = Services();

          final response = await services.getData('/posts/1');
          expect(response, {
            "userId": 1,
            "id": 1,
            "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
            "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
          });
        });

    test('putData sends a PUT request and handles a successful response',
        () async {
      final services = Services();

      final response = await services.putData(
        '/posts/1',
        headers: {'Content-Type': 'application/json'},
        body: {'title': 'Updated Title', 'body': 'Updated Body', 'userId': 1},
      );

      expect(response, {
        "title": "Updated Title",
        "body": "Updated Body",
        "userId": 1,
        "id": 1
      });
    });

    test('deleteData sends a DELETE request and handles a successful response',
        () async {
          final services = Services();

          final response = await services.deleteData(
            '/posts/1',
            headers: {'Content-Type': 'application/json'},
          );

          expect(response, {});
    });

    // TODO: Negative test cases?
  });
}
