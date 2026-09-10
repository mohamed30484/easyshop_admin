import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/admin_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.admin);

  final AdminEntity admin;

  @override
  List<Object?> get props => [admin];
}

class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

class ProfileUpdated extends ProfileState {
  const ProfileUpdated(this.admin);

  final AdminEntity admin;

  @override
  List<Object?> get props => [admin];
}

class ProfileUpdateFailure extends ProfileState {
  const ProfileUpdateFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
