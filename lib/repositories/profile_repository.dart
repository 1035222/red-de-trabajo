import '../models/app_user.dart';
import '../models/review.dart';
import '../models/portfolio_item.dart';

abstract class ProfileRepository {
  Future<AppUser> getUserProfile(String userId);
  Future<AppUser> updateUserProfile(AppUser user);
  Future<List<Review>> getUserReviews(String userId);
  Future<List<PortfolioItem>> getUserPortfolio(String userId);
}
