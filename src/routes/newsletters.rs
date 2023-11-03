use actix_web::HttpResponse;

//Dummy
pub async fn publish_newsletter() -> HttpResponse {
    HttpResponse::Ok().finish()
}
