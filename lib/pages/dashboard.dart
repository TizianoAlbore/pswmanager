class GroupColumnPage extends StatelessWidget {
  final FirebaseFirestore firestore;
  final String userId;
  final Color rowBorderColor;
  final Color headingColor;

  const GroupColumnPage({
    Key? key,
    required this.firestore,
    required this.userId,
    required this.rowBorderColor,
    required this.headingColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example of using the rowBorderColor and headingColor
    return ListView.builder(
      itemCount: 10,  // Example count, use actual data length
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          decoration: BoxDecoration(
            border: Border.all(color: rowBorderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            title: Text(
              'Row Heading $index',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: headingColor, // Apply heading color
              ),
            ),
            subtitle: Text('Row content for $index'),
          ),
        );
      },
    );
  }
}
