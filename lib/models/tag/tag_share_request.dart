enum TagSharePermission {
  READ,
  WRITE,
}

class TagShareRequest {
  final int sharedWithId;
  final TagSharePermission permission;

  TagShareRequest({
    required this.sharedWithId,
    required this.permission,
  });

  Map<String, dynamic> toJson() => {
    'sharedWithId': sharedWithId,
    'permission': permission.toString().split('.').last,
  };
} 