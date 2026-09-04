import '../models/user.dart';
import '../models/review.dart';
import '../models/portfolio_item.dart';

abstract class ProfileRepository {
  Future<User> getUserProfile(String userId);
  Future<User> updateUserProfile(User user);
  Future<List<Review>> getUserReviews(String userId);
  Future<List<PortfolioItem>> getUserPortfolio(String userId);
}
