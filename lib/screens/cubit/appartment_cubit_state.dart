part of 'appartment_cubit_cubit.dart';

sealed class AppartmentState extends Equatable {
  const AppartmentState();

  @override
  List<Object> get props => [];
}

final class AppartmentCubitInitial extends AppartmentState {}

final class ChangePhotoState extends AppartmentState {}

final class AppartmentLoading extends AppartmentState {}

final class AppartmentSuccess extends AppartmentState {}

final class AppartmentCubitError extends AppartmentState {
  final String message;
  const AppartmentCubitError({required this.message});
}
