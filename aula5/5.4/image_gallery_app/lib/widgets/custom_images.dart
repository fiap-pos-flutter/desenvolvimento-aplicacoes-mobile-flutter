part of '../screens/image_gallery_screen.dart';

class _CustomImages extends StatefulWidget {
  const _CustomImages({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  State<_CustomImages> createState() => __CustomImagesState();
}

class __CustomImagesState extends State<_CustomImages> {
  void _removeImage(int index) {
    setState(() {
      widget.images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 1.0,
      ),
      padding: const EdgeInsets.all(12.0),
      itemCount: widget.images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.imageView,
              arguments: widget.images[index],
            );
          },
          onLongPress: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete Image'),
                  content:
                      const Text('Are you sure you want to delete this image?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Delete',
                          style: TextStyle(color: AppColors.error)),
                      onPressed: () {
                        _removeImage(index);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: AppColors.error),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 8.0,
                  right: 8.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Tap to View',
                      style: TextStyle(
                          color: AppColors.background, fontSize: 12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
