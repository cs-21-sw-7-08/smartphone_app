


























/*

LatLng? position = await GeneralUtil.showPageAsDialog<LatLng?>(
          _buildContext, SelectLocationPage());
      if (position == null) return;
      GoogleServiceResponse<GoogleResponse> response =
          await GoogleService.getInstance().getAddressFromCoordinate(position);
      if (!response.isSuccess) {
        GeneralUtil.showToast(response.errorMessage!);
        return;
      }
 */