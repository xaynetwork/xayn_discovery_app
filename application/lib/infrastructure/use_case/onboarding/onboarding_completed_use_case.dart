import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

/// A [UseCase] that sets the onBoardingCompleted flag to true when
/// the onBoarding is completed.
@injectable
class OnOnBoardingCompletedUseCase extends UseCase<void, bool> {
  @override
  Stream<bool> transaction(void param) async* {
    /// TODO Store a flag to keep track that the onBoarding has been completed
    /// The structure will look like the following:
    /// try{
    ///   set and store isOnboardingCompleted flag to true
    ///   yield true;
    /// }catch(e){
    ///   throw error
    /// }
    yield true;
  }
}
